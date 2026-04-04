{ pkgs, ... }: {
  imports = [
    ../modules/base.nix
    ../modules/personal.nix
    ../modules/blue-team.nix
  ];

  home.username = "niax";
  home.homeDirectory = "/home/niax";

  sops.age.sshKeyPaths = [ "/home/niax/.ssh/id_ed25519" ];

  home.packages = [ pkgs.claude-code ];

  programs.keychain = {
    keys = [ "id_ed25519" ];
  };
}
