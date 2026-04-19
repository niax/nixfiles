{
  description = "niax nixfiles";

  inputs = {
    claude-code.url = "github:sadjow/claude-code-nix";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
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

  outputs = { nixpkgs, nixos-wsl, home-manager, nix-darwin, nixpkgs-darwin, claude-code, sops-nix, ... }:
    let
      mkDarwinOs = system: modules:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit sops-nix; };
          modules = [
            { nixpkgs.hostPlatform = system; }
            home-manager.darwinModules.home-manager
            { nixpkgs.overlays = [ claude-code.overlays.default ]; nixpkgs.config.allowUnfree = true; }
          ] ++ modules;
        };
      mkWslOs = modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit sops-nix; };
          modules = [
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
            ({ nixpkgs.overlays = [ claude-code.overlays.default ]; nixpkgs.config.allowUnfree = true; })
          ] ++ modules;
        };
      mkNixOs = modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit sops-nix; };
          modules = [
            home-manager.nixosModules.home-manager
            sops-nix.nixosModules.sops
          ] ++ modules;
        };
    in {
      homeManagerModules = {
        base = ./modules/base.nix;
        shell = ./modules/shell.nix;
        vim = ./modules/vim;
        tmux = ./modules/tmux;
      };

      darwinModules = {
        macos-yabai = ./modules/macos/yabai;
      };

      darwinConfigurations = {
        "lightcycle" = mkDarwinOs "aarch64-darwin" [ ./hosts/lightcycle.nix ];
      };

      nixosConfigurations = {
        "big-thunder" = mkWslOs [ ./hosts/big-thunder.nix ];
        "hotel-hightower" = mkWslOs [ ./hosts/hotel-hightower.nix ];
        "soarin" = mkNixOs [ ./hosts/soarin ];
      };
    };
}
