{ config, pkgs, lib, ... }:
{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    clock24 = true;
    historyLimit = 20000;
    keyMode = "vi";
    prefix = "C-a";
    secureSocket = false;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "screen-256color";
    extraConfig = builtins.concatStringsSep "\n" [
      (lib.strings.fileContents ./base.tmux)
      (lib.strings.fileContents ./keys.tmux)
      (lib.strings.fileContents ./theme.tmux)
    ];
  };
}
