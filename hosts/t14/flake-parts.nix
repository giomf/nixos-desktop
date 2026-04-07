{
  inputs,
  ...
}:

let
  hostName = "gwork";
in
{
  flake.nixosConfigurations = {
    ${hostName} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos."${hostName}"
        inputs.nixos-hardware.nixosModules.lenovo-thinkpad-l14-amd
        inputs.disko.nixosModules.disko
        {
          nixpkgs.overlays = [ inputs.nur.overlays.default ];
        }
      ];
    };
  };
}
