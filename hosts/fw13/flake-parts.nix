{
  inputs,
  ...
}:

let
  hostName = "glap";
in
{
  flake.nixosConfigurations = {
    ${hostName} = inputs.nixpkgs-unstable.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos."${hostName}"
        inputs.home-manager-unstable.nixosModules.home-manager
        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        inputs.disko.nixosModules.disko
        {
          nixpkgs.overlays = [ inputs.nur.overlays.default ];
        }
      ];
    };
  };
}
