{
  description = "System flake";
  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    # Nix user repositories
    nur.url = "github:nix-community/NUR";

    # WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  };

  outputs =
    {
      disko,
      cosmic-manager,
      home-manager,
      nixos-hardware,
      nixos-wsl,
      nixpkgs,
      nur,
      ...
    }:
    {
      nixosConfigurations = {
        "glap" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/framework13
            disko.nixosModules.disko
            nixos-hardware.nixosModules.framework-13-7040-amd
            {
              nixpkgs.overlays = [ nur.overlays.default ];
            }
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                extraSpecialArgs = {
                  inherit cosmic-manager;
                };
              };
            }
          ];
        };

        "wsl" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/wsl
            nixos-wsl.nixosModules.wsl
            home-manager.nixosModules.home-manager
          ];
        };
      };
      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            just
          ];
        };
    };
}
