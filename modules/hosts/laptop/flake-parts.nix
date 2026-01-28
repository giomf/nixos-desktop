{
  inputs,
  lib,
  ...
}:

let
  hostName = "glap";
in
{
  flake.nixosConfigurations = {
    ${hostName} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos."${hostName}"
        inputs.nixos-hardware.nixosModules.framework-13-7040-amd
        inputs.disko.nixosModules.disko
        {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          nixpkgs.overlays = [ inputs.nur.overlays.default ];
        }
      ];
    };
  };
}
