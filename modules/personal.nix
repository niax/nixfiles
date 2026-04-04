{ config, pkgs, lib, ... }: {
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
}
