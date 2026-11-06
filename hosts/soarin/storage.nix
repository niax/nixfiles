{ ... }:

# Multi-device bcachefs pool (nvme1n1 + nvme2n1), labelled "storage".
{
  boot.supportedFilesystems = [ "bcachefs" ];

  fileSystems."/srv" = {
    device = "LABEL=storage";
    fsType = "bcachefs";
    options = [ "nofail" ];
  };

  # niax's space on the pool, surfaced in their home dir (and so via Samba too).
  systemd.tmpfiles.rules = [
    "d /srv/niax 0700 niax users -"
  ];

  fileSystems."/home/niax/storage" = {
    device = "/srv/niax";
    fsType = "none";
    options = [
      "bind"
      "nofail"
      "x-systemd.requires-mounts-for=/srv"
    ];
  };
}
