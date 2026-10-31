{ ... }:

{
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  systemd.tmpfiles.rules = [
    "d /var/lib/unifi-os-server 0750 root root -"
    # 0755: these are bind-mount roots for the container. Docker/Podman
    # normally auto-create bind-mount sources at 0755; the various
    # in-container services (postgres, mongodb, rabbitmq, ...) run as
    # non-root users that are not in the root group, so anything more
    # restrictive than o+rx here blocks them from traversing into the
    # subdirectories they otherwise own (e.g. postgres initdb failing
    # with "Permission denied" on /data/postgresql/... even though that
    # subtree itself is postgres:postgres).
    "d /var/lib/unifi-os-server/persistent 0755 root root -"
    "d /var/lib/unifi-os-server/var-log 0755 root root -"
    "d /var/lib/unifi-os-server/data 0755 root root -"
    "d /var/lib/unifi-os-server/srv 0755 root root -"
    "d /var/lib/unifi-os-server/var-lib-unifi 0755 root root -"
    "d /var/lib/unifi-os-server/var-lib-mongodb 0755 root root -"
    "d /var/lib/unifi-os-server/etc-rabbitmq-ssl 0755 root root -"
  ];

  virtualisation.oci-containers.containers.unifi-os-server = {
    image = "ghcr.io/lemker/unifi-os-server:latest";
    autoStart = true;

    environment = {
      UOS_SYSTEM_IP = "10.0.80.6";
    };

    volumes = [
      "/sys/fs/cgroup:/sys/fs/cgroup:rw"
      "/var/lib/unifi-os-server/persistent:/persistent"
      "/var/lib/unifi-os-server/var-log:/var/log"
      "/var/lib/unifi-os-server/data:/data"
      "/var/lib/unifi-os-server/srv:/srv"
      "/var/lib/unifi-os-server/var-lib-unifi:/var/lib/unifi"
      "/var/lib/unifi-os-server/var-lib-mongodb:/var/lib/mongodb"
      "/var/lib/unifi-os-server/etc-rabbitmq-ssl:/etc/rabbitmq/ssl"
    ];

    # UOS_SYSTEM_IP gets its own address (10.0.80.6) on enp87s0 so the
    # controller's ports don't collide with anything bound on soarin's
    # main address (10.0.80.5).
    ports = [
      "10.0.80.6:11443:443"
      "10.0.80.6:8080:8080"
      "10.0.80.6:3478:3478/udp"
      "10.0.80.6:10003:10003/udp"
    ];

    extraOptions = [
      "--cgroupns=host"
      "--cap-add=NET_ADMIN"
      "--cap-add=NET_RAW"
      "--add-host=host.docker.internal:host-gateway"
      "--tmpfs=/run:exec"
      "--tmpfs=/run/lock"
      "--tmpfs=/tmp:exec"
      "--tmpfs=/var/lib/journal"
      "--tmpfs=/var/opt/unifi/tmp:size=64m"
    ];
  };

  networking.firewall.interfaces.enp87s0 = {
    allowedTCPPorts = [ 11443 8080 ];
    allowedUDPPorts = [ 3478 10003 ];
  };
}
