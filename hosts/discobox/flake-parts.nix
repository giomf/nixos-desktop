{
  inputs,
  ...
}:

let
  hostName = "discobox";
in
{
  flake.nixosConfigurations = {
    ${hostName} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos.${hostName}
        inputs.home-manager.nixosModules.home-manager
      ];
    };
  };
}
