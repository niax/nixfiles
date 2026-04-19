{ pkgs, ... }: {
  imports = [ ./niax-user.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  wsl.enable = true;
  wsl.defaultUser = "niax";

  environment.systemPackages = with pkgs; [
    git
    vim
  ];
  programs.zsh.enable = true;
  services.openssh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
