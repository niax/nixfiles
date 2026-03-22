{ config, pkgs, lib, ... }: {

  imports = [
    ./all-nodes.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "niax";
  home.homeDirectory = "/home/niax";

  programs.git = {
    settings = {
      user = {
        name = "Nicholas Hollett";
        email = "niax@niax.co.uk";
      };
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.keychain = {
    keys = [
      "id_ecdsa"
      "id_ed25519"
      "id_rsa"
    ];
  };

  programs.zsh.envExtra = builtins.concatStringsSep "\n" [
    ''
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
      if [ -e "$HOME/.cargo/env" ]; then
        . "$HOME/.cargo/env"
      fi
    ''
  ];
}
