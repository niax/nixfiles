{ config, pkgs, lib, ... }: {

  imports = [
    ./all-nodes.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "niax";
  home.homeDirectory = "/home/niax";

  programs.git = {
    userName = "Nicholas Hollett";
    userEmail = "niax@niax.co.uk";
	extraConfig = {
	  init = {
	    defaultBranch = "main";
	  };
	};
  };

  programs.zsh.envExtra = builtins.concatStringsSep "\n" [
  	''
	. "$HOME/.nix-profile/etc/profile.d/nix.sh"
	if [ -e "$HOME/.cargo/env" ]; then
		. "$HOME/.cargo/env"
	fi
	''
  ];
}
