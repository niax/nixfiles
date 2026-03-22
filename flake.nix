{
  description = "niax home-manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # Helper to build a homeConfiguration for a given system + module
      mkHome = system: module:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [ module ];
        };
    in {
      homeConfigurations = {
        # Windows/WSL
        "niax@big-thunder" = mkHome "x86_64-linux" ./home-windows.nix;
      };
    };
}
