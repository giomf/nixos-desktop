{
  inputs,
  ...
}:
let
  hostName = "moon";
in
{
  flake.modules.nixos."${hostName}-server" = {
    imports = with inputs.self.modules.nixos; [
      # Base
      system-server

      # User
      guif
      secrets
      zfs
      zfs-zed
      syncoid
    ];

    mine.zfs.pools = [ "garage" ];
    mine.zfs.sanoid.autosnap = false;
    mine.zfs.syncoid.commands = {
      truck = {
        source = "syncoid@guif.dev:truck";
        target = "garage/truck";
      };
      lambo = {
        source = "syncoid@guif.dev:lambo";
        target = "garage/lambo";
      };
    };

    home-manager.users.guif = {
      imports = with inputs.self.modules.homeManager; [
        system-default
      ];
    };

    system.stateVersion = "24.05";
  };
}
