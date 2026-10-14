{

  flake.modules.nixos.backup-server = {
    disko.devices = {
      disk = {
        boot = {
          device = "/dev/disk/by-id/usb-Ut163_USB2FlashStorage_080229f393c35d-0:0";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              boot = {
                size = "1M";
                type = "EF02"; # for grub MBR
              };
            };
          };
        };
        nixos = {
          device = "/dev/disk/by-id/wwn-0x5002538e405d6f0a";
          type = "disk";
          content = {
            type = "gpt";
            partitions = {
              root = {
                size = "100%";
                priority = 1;
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };
    };
  };
}
