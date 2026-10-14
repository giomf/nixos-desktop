{ inputs, lib, ... }:
{
  imports = [ inputs.flake-file.flakeModules.default ];

  flake-file = {
    description = "System flake";

    outputs = ''
      inputs:
      inputs.flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [
          (inputs.import-tree ./flake)
          (inputs.import-tree ./hosts)
          (inputs.import-tree ./modules)
        ];
      }
    '';

    inputs = {
      flake-file.url = lib.mkDefault "github:denful/flake-file";

      # Stable channel, used by the servers
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
      home-manager = {
        url = "github:nix-community/home-manager/release-26.05";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      # Unstable channel, used by the desktops
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      home-manager-unstable = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs-unstable";
      };

      # Nix user repositories
      nur.url = "github:nix-community/NUR";

      import-tree.url = "github:vic/import-tree";

      # Disk partitioning
      disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixos-hardware.url = "github:NixOS/nixos-hardware/master";

      flake-parts = {
        url = "github:hercules-ci/flake-parts";
        inputs.nixpkgs-lib.follows = "nixpkgs";
      };
    };
  };
}
