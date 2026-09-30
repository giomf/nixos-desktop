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

      nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

      # Nix user repositories
      nur.url = "github:nix-community/NUR";

      import-tree.url = "github:vic/import-tree";

      # Disk partitioning
      disko = {
        url = "github:nix-community/disko";
        inputs.nixpkgs.follows = "nixpkgs";
      };

      nixos-hardware.url = "github:NixOS/nixos-hardware/master";

      flake-parts.url = "github:hercules-ci/flake-parts";
    };
  };
}
