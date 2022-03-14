{ config, pkgs, lib, ... }: {

  imports = [
    ./vim
	./shell.nix
  ];

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "niax";
  home.homeDirectory = "/home/niax";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  home.packages = [
      pkgs.tmux
      pkgs.poetry
	  pkgs.ripgrep
	  pkgs.go
	  pkgs.tig
  ];

  home.file.".tmux.conf".source = ./tmux.conf;

  programs.git = {
    enable = true;
	ignores = [
	  "*.swp"
	];
  };
}
