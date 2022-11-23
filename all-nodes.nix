{ config, pkgs, lib, ... }: {

  imports = [
    ./tmux
    ./vim
    ./shell.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  home.packages = with pkgs; [
    # Terminal things
    jq
    ripgrep
    visidata

    # Dev tools
    tig
    poetry
    inotify-tools
    awscli2

    # Programming languages
    go
    python39
  ];

  programs.git = {
    enable = true;
    ignores = [
      "*.swp"
    ];
  };

  programs.keychain = {
    enable = true;
  };
}
