{
  ...
}:
{

  flake.modules.nixos.gwork =
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
            ];
          };
        };
      };
    };
}
