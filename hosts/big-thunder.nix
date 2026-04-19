{ pkgs, ... }: {
  imports = [ ../modules/wsl-host.nix ];

  system.stateVersion = "25.11"; # NO TOUCH ME!

  networking.hostName = "big-thunder";

  home-manager.users.niax = {
    imports = [
      ../modules/base.nix
      ../modules/personal.nix
      ({ pkgs, ... }: {
        home.packages = [ pkgs.claude-code ];

        programs.keychain = {
          keys = [ "id_ed25519" ];
        };
      })
    ];
  };
}
