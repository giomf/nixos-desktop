{ ... }:
{

  flake.modules.nixos.backup-server = {
    networking = {
      hostName = "backup";
      hostId = "4461fd14";
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
          matchConfig.PermanentMACAddress = "1c:98:ec:0f:ab:54";
          linkConfig.Name = "lan1";
        };
        "20-lan-2" = {
          matchConfig.PermanentMACAddress = "1c:98:ec:0f:ab:55";
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
