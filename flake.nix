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
        # Windows/WSL
        "niax@big-thunder" = mkHome "x86_64-linux" [ ./home-windows.nix ];

        # Mac
        "niax@lightcycle" = mkHome "aarch64-darwin" [ ./home-mac.nix ];
      };
      nixosConfigurations."hotel-hightower" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ({pkgs, config, ...}: {
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            sops.defaultSopsFile = ./secrets/hotel-hightower.yaml;
            sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

            nixpkgs.overlays = [ claude-code.overlays.default ];
            nixpkgs.config.allowUnfree = true;

            wsl.enable = true;
            wsl.defaultUser = "niax";

            system.stateVersion = "25.11"; # NO TOUCH ME!

            networking.hostName = "hotel-hightower";

            environment.systemPackages = with pkgs; [
              git
              vim
            ];
            programs.zsh.enable = true;
            services.openssh.enable = true;

            users.users.niax = {
              isNormalUser = true;
              home = "/home/niax";
              description = "niax";
              extraGroups = [
                "wheel"
              ];
              shell = pkgs.zsh;
            };
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [
                sops-nix.homeManagerModules.sops
                { sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; }
              ];

              users.niax = {...}: {
                imports = [
                  ./home-windows.nix
                  ./blue-team.nix
                ];
              };
            };
          })
        ];
      };
    };
}
