{ config, pkgs, ... }:
let
  sopsFile = ../../secrets/soarin.yaml;
  snmpExporter = config.services.prometheus.exporters.snmp;
  nodeExporter = config.services.prometheus.exporters.node;
  localJob = job_name: port: {
    inherit job_name;
    scrape_interval = "15s";
    static_configs = [
      {
        targets = [ "127.0.0.1:${toString port}" ];
        labels.instance = config.networking.hostName;
      }
    ];
  };
  grafanaSecret = {
    inherit sopsFile;
    owner = "grafana";
    restartUnits = [ "grafana.service" ];
  };
in {
  sops.secrets.snmp_community = { inherit sopsFile; };
  sops.secrets.grafana_secret_key = grafanaSecret;
  sops.secrets.grafana_admin_password = grafanaSecret;

  # snmp_exporter doesn't expand environment variables in community strings
  # (only in v3 credentials), so the auth section is rendered as its own file.
  sops.templates."snmp-auth.yml" = {
    content = builtins.toJSON {
      auths.lan_v2 = {
        community = config.sops.placeholder.snmp_community;
        version = 2;
      };
    };
    restartUnits = [ "prometheus-snmp-exporter.service" ];
  };

  services.prometheus.exporters.snmp = {
    enable = true;
    listenAddress = "127.0.0.1";
    # The metric modules that ship with the exporter. Copied so that this is a
    # store path in its own right, which the module's config check requires.
    configurationPath = pkgs.runCommand "snmp.yml" { } ''
      cp ${pkgs.prometheus-snmp-exporter.src}/snmp.yml $out
    '';
    extraFlags = [ "--config.file=%d/snmp-auth.yml" ];
  };

  systemd.services.prometheus-snmp-exporter.serviceConfig.LoadCredential =
    "snmp-auth.yml:${config.sops.templates."snmp-auth.yml".path}";

  # The systemd collector reports unit state, including failed units.
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";
    enabledCollectors = [ "systemd" ];
  };

  # CPU and memory per cgroup, which covers systemd units and also the units
  # inside the UniFi container. systemd_exporter reports no per-unit CPU here.
  services.cadvisor = {
    enable = true;
    listenAddress = "127.0.0.1";
    port = 9338;
    extraOptions = [
      "-enable_metrics=cpu,memory"
      "-housekeeping_interval=15s"
    ];
  };

  # Latency and loss towards the router and the internet, to tell a LAN problem
  # from an upstream one. Rendered by dashboards/smokeping.json.
  services.prometheus.exporters.smokeping = {
    enable = true;
    listenAddress = "127.0.0.1";
    hosts = [
      "10.0.80.1"
      "1.1.1.1"
      "8.8.8.8"
    ];
    # The default buckets double in size, which is too coarse to see jitter at
    # the single-digit milliseconds these targets sit at.
    buckets = builtins.concatStringsSep "," [
      "0.0001" "0.0002" "0.0003" "0.0005" "0.00075"
      "0.001" "0.0015" "0.002" "0.003" "0.004" "0.005" "0.006" "0.007" "0.008" "0.009"
      "0.01" "0.0125" "0.015" "0.02" "0.025" "0.03" "0.04" "0.05" "0.075"
      "0.1" "0.15" "0.2" "0.3" "0.5"
      "1" "2" "5"
    ];
  };

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    retentionTime = "1y";
    globalConfig.scrape_interval = "1m";
    scrapeConfigs = [
      {
        job_name = "snmp";
        metrics_path = "/snmp";
        params = {
          auth = [ "lan_v2" ];
          module = [ "system" "if_mib" "mikrotik" "hrDevice" "hrStorage" ];
        };
        static_configs = [ { targets = [ "10.0.80.1" ]; } ];
        relabel_configs = [
          { source_labels = [ "__address__" ]; target_label = "__param_target"; }
          { source_labels = [ "__param_target" ]; target_label = "instance"; }
          { target_label = "__address__"; replacement = "127.0.0.1:${toString snmpExporter.port}"; }
        ];
      }
      (localJob "node" nodeExporter.port)
      (localJob "cadvisor" config.services.cadvisor.port)
      (localJob "smokeping" config.services.prometheus.exporters.smokeping.port)
    ];
  };

  # Not opened in the firewall, so this is only reachable over tailscale0.
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
      };
      security = {
        admin_password = "$__file{${config.sops.secrets.grafana_admin_password.path}}";
        secret_key = "$__file{${config.sops.secrets.grafana_secret_key.path}}";
      };
    };
    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            uid = "prometheus";
            type = "prometheus";
            url = "http://127.0.0.1:${toString config.services.prometheus.port}";
            isDefault = true;
          }
        ];
      };
      dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "soarin";
            options.path = "${./dashboards}";
          }
        ];
      };
    };
  };
}
