{ config, pkgs, lib, ... }: {

  imports = [
    ./personal.nix
    ./windows
  ];

  home.packages = with pkgs; [
    claude-code
  ];
}
