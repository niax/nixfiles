{ config, lib, ... }:

let
  sopsFile = ../../secrets/soarin.yaml;

  # user -> sops secret holding their Samba password
  sambaUsers = {
    niax = "samba_niax_password";
  };
in
{
  sops.secrets = lib.genAttrs (lib.attrValues sambaUsers) (_: {
    inherit sopsFile;
    restartUnits = [ "samba-provision.service" ];
  });

  services.samba = {
    enable = true;
    # Only SMB2+ over 445; no NetBIOS/SMB1.
    nmbd.enable = false;
    winbindd.enable = false;
    openFirewall = false;

    settings = {
      global = {
        "server string" = "soarin";
        "server min protocol" = "SMB2_10";
        "disable netbios" = "yes";
        "smb ports" = "445";

        security = "user";
        "map to guest" = "never";

        "hosts allow" = "10.0.80.0/24 10.0.89.0/24 100.64.0.0/10 127.0.0.1 ::1";
        "hosts deny" = "ALL";

        # macOS Finder interoperability
        "vfs objects" = "fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:posix_rename" = "yes";
        "fruit:veto_appledouble" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
      };

      # No path: Samba uses the user's home directory from passwd.
      homes = {
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "%S";
      };
    };
  };

  # Syncs each user's Samba password from sops into Samba's passdb
  # (smbpasswd -a adds or updates).
  systemd.services.samba-provision = {
    description = "Provision Samba user passwords";
    wantedBy = [ "samba-smbd.service" ];
    before = [ "samba-smbd.service" ];
    path = [ config.services.samba.package ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = lib.concatStrings (
      lib.mapAttrsToList (user: secret: ''
        pw=$(cat ${config.sops.secrets.${secret}.path})
        printf '%s\n%s\n' "$pw" "$pw" | smbpasswd -s -a ${user}
      '') sambaUsers
    );
  };

  # Windows network discovery (Samba no longer does this without NetBIOS).
  services.samba-wsdd = {
    enable = true;
    openFirewall = false;
  };

  networking.firewall.interfaces.enp87s0 = {
    allowedTCPPorts = [
      445 # SMB
      5357 # wsdd
    ];
    allowedUDPPorts = [
      3702 # wsdd
    ];
  };
}
