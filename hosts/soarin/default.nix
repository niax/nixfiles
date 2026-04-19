{ pkgs, config, sops-nix, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11"; # NO TOUCH ME!

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.hostName = "basestar";

  networking.dhcpcd.enable = false;
  networking.interfaces.enp87s0 = {
    ipv4.addresses = [
      {
        address = "10.0.80.5";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = "10.0.80.1";
  networking.nameservers = [
    "8.8.8.8"
    "8.8.4.4"
  ];

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  users.users.niax = {
    isNormalUser = true;
    home = "/home/niax";
    description = "niax";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMI6YMzipLPfoK9iX1jDIY1KGwsxh5K2eta+gk5jwGx big-thunder"
    ];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      sops-nix.homeManagerModules.sops
      { sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; }
    ];
    users.niax = {
      imports = [
        ../../modules/base.nix
        ../../modules/personal.nix
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  programs.zsh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Enable tailscale
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    extraSetFlags = [
      "--advertise-exit-node"
      "--advertise-routes=10.0.89.0/24"
      "--snat-subnet-routes=false"
    ];
  };
  systemd.services.tailscaled.serviceConfig.Environment = [
    # Force nftables
    "TS_DEBUG_FIREWALL_MODE=nftables"
  ];

  # Advertise routes learned from tailscale towards CPE
  services.bird = {
    enable = true;
    config = ''
    router id 10.0.80.5;

    filter tailscale_routes {
      # Only import Tailscale routes
      if net ~ [ 100.64.0.0/10{32,32} ] then accept;
      reject;
    }

    protocol kernel tailscale_table {
      kernel table 52;  # Tailscale's table
      learn;
      ipv4 {
        table master4;
        import filter tailscale_routes;
        #import all;
        export none;
      };
    }

    protocol device {
      scan time 10;
    }

    protocol bgp upstream {
      local 10.0.80.5 as 65001;
      neighbor 10.0.80.1 as 65001;
      ipv4 {
        import none;
        export filter tailscale_routes;
      };
    }
    '';
  };

  # Open ports in the firewall.
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "tailscale0" ];

    allowedTCPPorts = [
      22
    ] ++ config.services.openssh.ports;

    allowedUDPPorts = [
      config.services.tailscale.port
    ];
  };

}

