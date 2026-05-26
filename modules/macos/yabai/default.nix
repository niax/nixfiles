{ config, pkgs, lib, ... }:
let
  yabaiJson = pkgs.runCommand "yabai-karabiner.json" {
    nativeBuildInputs = [ pkgs.python3 ];
    script = pkgs.replaceVars ./make_yabai.py { yabai = pkgs.yabai; };
  } "python3 $script > $out";
in {
  services.yabai = {
    enable = true;
    extraConfig = builtins.readFile ./yabairc;
  };

  home-manager.users.niax = { ... }: {
    home.file.".config/karabiner/assets/complex_modifications/yabai.json" = {
      source = yabaiJson;
      onChange = "launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server";
    };
  };
}
