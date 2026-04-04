{ config, pkgs, lib, ... }: {
  home.file.".config/yabai/yabairc" = {
    source = ./yabairc;
    executable = true;
    onChange = "brew services restart yabai";
  };

  home.file.".config/karabiner/make_yabai.py" = {
    source = ./make_yabai.py;
    executable = true;
    onChange = "python ~/.config/karabiner/make_yabai.py > ~/.config/karabiner/assets/complex_modifications/yabai.json";
  };
}
