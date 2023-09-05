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
    htop
    visidata

    # Network things
    nmap

    # Dev tools
    tig
    poetry
    awscli2

    # Programming languages
    go
    python39
  ] ++ lib.optionals stdenv.isLinux [
    inotify-tools
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
