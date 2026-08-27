{ config, pkgs, lib, ... }:
let
  cfg = config.yabaiKarabiner;
  yabaiJson = pkgs.runCommand "yabai-karabiner.json" {
    nativeBuildInputs = [ pkgs.python3 ];
    script = pkgs.replaceVars ./make_yabai.py { yabai = pkgs.yabai; };
  } "python3 $script > $out";
in {
  options.yabaiKarabiner.users = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = lib.optional (config.system.primaryUser != null) config.system.primaryUser;
    defaultText = lib.literalExpression "lib.optional (config.system.primaryUser != null) config.system.primaryUser";
    example = [ "niax" ];
    description = ''
      Users to install the yabai Karabiner-Elements complex modification for.
      Each must have a home-manager configuration.
    '';
  };

  config = {
    services.yabai = {
      enable = true;
      extraConfig = builtins.readFile ./yabairc;
    };

    home-manager.users = lib.genAttrs cfg.users (_: { ... }: {
      home.file.".config/karabiner/assets/complex_modifications/yabai.json" = {
        source = yabaiJson;
        onChange = "launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server";
      };
    });
  };
}
