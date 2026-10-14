{
  inputs,
  ...
}:

let
  hostName = "gwork";
in
{
  flake.nixosConfigurations = {
    ${hostName} = inputs.nixpkgs-unstable.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos."${hostName}"
        inputs.home-manager-unstable.nixosModules.home-manager
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
        inputs.disko.nixosModules.disko
        {
          nixpkgs.overlays = [ inputs.nur.overlays.default ];
        }
      ];
    };
  };
}
