{ ... }:
{

  flake.modules.nixos.main-server = {
    networking = {
      hostName = "main";
      hostId = "d7710e38";
      useNetworkd = true;
      networkmanager.enable = false;
      firewall.enable = true;
    };

    systemd.network = {
      enable = true;
      # broken: https://github.com/NixOS/nixpkgs/issues/247608
      wait-online.enable = false;
      links = {
        "10-lan-1" = {
          matchConfig.PermanentMACAddress = "3c:ec:ef:c2:4f:c8";
          linkConfig.Name = "lan1";
        };
        "20-lan-2" = {
          matchConfig.PermanentMACAddress = "3c:ec:ef:c2:4f:c9";
          linkConfig.Name = "lan2";
        };
      };
      networks = {
        "10-lan-1" = {
          matchConfig.Name = "lan1";
          networkConfig.DHCP = "yes";
          linkConfig.RequiredForOnline = "no";
        };
        "20-lan-2" = {
          matchConfig.Name = "lan2";
          networkConfig.DHCP = "yes";
          linkConfig.RequiredForOnline = "no";
        };
      };
    };
  };
}
