{ pkgs, ... }: {
  users.users.niax = {
    isNormalUser = true;
    home = "/home/niax";
    description = "niax";
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINMI6YMzipLPfoK9iX1jDIY1KGwsxh5K2eta+gk5jwGx big-thunder"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP7VHoCSmHl3P53AYSAsDBVxV4v9qTyaYqnp/a4KMy9z lightcycle"
    ];
  };
}
