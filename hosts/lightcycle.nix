{ pkgs, lib, config, ... }: {
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

  imports = [
    ../modules/base.nix
    ../modules/personal.nix
    ../modules/macos/yabai
  ];

  home.username = "niax";
  home.homeDirectory = lib.mkForce "/Users/niax";

  home.packages = [ pkgs.claude-code ];

  programs.keychain = {
    keys = [ "id_ed25519" ];
  };
}
