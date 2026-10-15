{ ... }:
{
  flake.modules.nixos.earth-server =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        # used by zfs send/receive
        pv
        mbuffer
        lzop
        zstd
      ];

      # Permissions on datasets: https://github.com/jimsalterjrs/sanoid/wiki/Syncoid#running-without-root
      # sudo zfs allow -u syncoid send,hold,mount,snapshot,destroy truck
      users = {
        users = {
          "syncoid" = {
            createHome = false;
            extraGroups = [ "ssh" ];
            group = "syncoid";
            home = "/var/empty";
            isNormalUser = true;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIErIT04hD1d0A30rz537SFz30Oz+qB/ovf5P8Ow+I4io syncoid@backup"
            ];
          };
        };
        groups.syncoid = { };
      };
    };
}
