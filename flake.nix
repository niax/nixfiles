{
  description = "niax nixfiles";

  inputs = {
    claude-code.url = "github:sadjow/claude-code-nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos-wsl, home-manager, claude-code, sops-nix, ... }:
    let
      mkHome = system: modules:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ claude-code.overlays.default ];
            config.allowUnfree = true;
          };
          modules = [ sops-nix.homeManagerModules.sops ] ++ modules;
        };
    in {
      homeConfigurations = {
        "niax@lightcycle"  = mkHome "aarch64-darwin" [ ./hosts/lightcycle.nix ];
      };

      nixosConfigurations = {
        "big-thunder" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit sops-nix; };
          modules = [
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ({ nixpkgs.overlays = [ claude-code.overlays.default ]; nixpkgs.config.allowUnfree = true; })
            ./hosts/big-thunder.nix
          ];
        };

        "hotel-hightower" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit sops-nix; };
          modules = [
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ({ nixpkgs.overlays = [ claude-code.overlays.default ]; nixpkgs.config.allowUnfree = true; })
            ./hosts/hotel-hightower.nix
          ];
        };
      };
    };
}
