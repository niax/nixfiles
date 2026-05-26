{ pkgs, sops-nix, lib, ... }: {
  imports = [ ../modules/macos/yabai ];

  networking.hostName = "lightcycle";
  system.stateVersion = 5;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.primaryUser = "niax";
  users.users.niax.home = "/Users/niax";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      sops-nix.homeManagerModules.sops
      { sops.age.keyFile = "/Users/niax/.config/sops/age/keys.txt"; }
    ];
    users.niax = {
      imports = [
        ../modules/base.nix
        ../modules/personal.nix
        ../modules/blue-team.nix
        ({ pkgs, ... }: {
          home.username = "niax";
          home.homeDirectory = "/Users/niax";

          home.packages = [ pkgs.claude-code ];

          programs.keychain = {
            keys = [ "id_ed25519" ];
          };
        })
      ];
    };
  };
}
