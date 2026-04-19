{ pkgs, ... }: {
  imports = [ ../modules/wsl-host.nix ];

  system.stateVersion = "25.11"; # NO TOUCH ME!

  networking.hostName = "hotel-hightower";

  home-manager.users.niax = {
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
}
