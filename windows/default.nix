{ config, pkgs, lib, ... }: {
  home.file.".zshrc-local".source = ./zshrc-local;
}
