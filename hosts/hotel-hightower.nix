{ pkgs, sops-nix, ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  wsl.enable = true;
  wsl.defaultUser = "niax";

  system.stateVersion = "25.11"; # NO TOUCH ME!

  networking.hostName = "hotel-hightower";

  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  programs.zsh.enable = true;
  services.openssh.enable = true;

  users.users.niax = {
    isNormalUser = true;
    home = "/home/niax";
    description = "niax";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
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
        ../modules/base.nix
        ../modules/personal.nix
        ../modules/blue-team.nix
        ({ pkgs, ... }: {
          home.packages = [ pkgs.claude-code ];

          programs.keychain = {
            keys = [ "id_ed25519" ];
          };
        })
      ];
    };
  };
}
