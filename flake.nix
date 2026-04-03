{
  description = "niax home-manager";

  inputs = {
    claude-code.url = "github:sadjow/claude-code-nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, claude-code, ... }:
    let
      # Helper to build a homeConfiguration for a given system + module
      mkHome = system: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ claude-code.overlays.default ];
            config.allowUnfree = true;
          };
          modules = [ module ];
        };
    in {
      homeConfigurations = {
        # Windows/WSL
        "niax@big-thunder" = mkHome "x86_64-linux" ./home-windows.nix;

        # Mac
        "niax@lightcycle" = mkHome "aarch64-darwin" ./home-mac.nix;
      };
    };
}
