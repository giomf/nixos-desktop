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

    import-tree.url = "github:vic/import-tree";

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

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      let
        treeModules = inputs.import-tree ./modules;
        treeHosts = inputs.import-tree ./hosts;
      in
      {
        imports = [
          treeModules
          treeHosts
          inputs.flake-parts.flakeModules.modules
        ];
        debug = true;
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            config,
            self',
            inputs',
            pkgs,
            system,
            ...
          }:
          {
            devShells.default = pkgs.mkShell {
              nativeBuildInputs = with pkgs; [
                just
                nh
                nixos-rebuild-ng
                nix-output-monitor
              ];
            };
          };
      }
    );

}
