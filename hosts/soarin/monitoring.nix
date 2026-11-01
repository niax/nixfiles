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

  # The exporter holds the community string and will query whatever target it's
  # given, so it stays on loopback. Prometheus has no auth, so it does too.
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
    # The default, 8080, is the UniFi container's port on 10.0.80.6.
    port = 9338;
    extraOptions = [
      "-enable_metrics=cpu,memory"
      "-housekeeping_interval=15s"
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
