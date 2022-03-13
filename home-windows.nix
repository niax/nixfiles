{ config, pkgs, lib, ... }: {

  imports = [
    ./personal.nix
    ./windows
  ];
}
