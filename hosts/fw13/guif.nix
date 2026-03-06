{
  inputs,
  ...
}:
{

  flake.modules.nixos.glap =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      users = {
        users = {
          guif = {
            extraGroups = [
              "networkmanager"
              "dialout"
            ];
          };
        };
      };
    };
}
