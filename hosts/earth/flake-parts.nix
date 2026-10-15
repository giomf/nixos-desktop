{
  inputs,
  ...
}:

let
  hostName = "earth";
in
{
  flake.nixosConfigurations = {
    ${hostName} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos."${hostName}-server"
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
      ];
    };
  };
}
