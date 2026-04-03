{ config, pkgs, lib, ... }: {

  imports = [
    ./personal.nix
    ./macos/yabai
  ];

  home.homeDirectory = lib.mkForce "/Users/niax";

  home.packages = with pkgs; [
    claude-code
  ];
}
