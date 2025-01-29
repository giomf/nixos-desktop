{
  description = "System flake";
  inputs = {

    ### Stable
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager-stable = {
      # url = "github:nix-community/home-manager/release-24.11";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    # Nix user repositories
    nur.url = "github:nix-community/NUR";

    # WSL
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    ### Unstable
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # nixos-cosmic = {
    #   url = "github:lilyinstarlight/nixos-cosmic";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  };

  outputs =
    {
      disko,
      home-manager-stable,
      home-manager-unstable,
      nixos-hardware,
      nixos-wsl,
      nixpkgs-stable,
      nixpkgs-unstable,
      nur,
      # nixos-cosmic,
      ...
    }:
    {
      nixosConfigurations = {
        "glap-old" = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/l380
            nixos-hardware.nixosModules.lenovo-thinkpad-l13
            # {
            #   nix.settings = {
            #     substituters = [ "https://cosmic.cachix.org/" ];
            #     trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            #   };
            # }
            # nixos-cosmic.nixosModules.default
            home-manager-unstable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.guif = ./hosts/l380/home.nix;
              nixpkgs.overlays = [ nur.overlay ];
            }
          ];
        };

        "glap" = nixpkgs-unstable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/framework13
            disko.nixosModules.disko
            nixos-hardware.nixosModules.framework-13-7040-amd
            home-manager-unstable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.guif = ./hosts/l380/home.nix;
              nixpkgs.overlays = [ nur.overlay ];
            }
          ];
        };

        "wsl" = nixpkgs-stable.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/wsl
            nixos-wsl.nixosModules.wsl
            home-manager-stable.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.guif = ./hosts/wsl/home.nix;
            }
          ];
        };
      };
      devShells.x86_64-linux.default =
        let
          pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            just
          ];
        };
    };
}
