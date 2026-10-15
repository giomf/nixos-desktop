{ inputs, ... }:
{
  # PublicKey: 0bJ5UDH0CRweZicO8kvIl+xp5z5Mswvfp81H5tfKOFY=
  flake.modules.nixos.wireguard =
    { config, ... }:
    {
      age.secrets.wireguard-key = {
        file = "${inputs.self.outPath}/secrets/wireguard-key.age";
        mode = "640";
        owner = "systemd-network";
        group = "systemd-network";
      };

      networking = {
        nat = {
          enable = true;
          externalInterface = "lan2";
          internalInterfaces = [ "wg0" ];
        };
        firewall.allowedUDPPorts = [ 51820 ];
      };

      systemd.network = {
        enable = true;
        networks."50-wg0" = {
          matchConfig.Name = "wg0";
          address = [
            "192.168.26.1/32"
          ];
          networkConfig = {
            # do not use IPMasquerade,
            # unnecessary, causes problems with host ipv6
            IPv4Forwarding = true;
            #IPv6Forwarding = true;
          };
        };

        netdevs."50-wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
          };

          wireguardConfig = {
            ListenPort = 51820;

            # ensure file is readable by `systemd-network` user
            PrivateKeyFile = config.age.secrets.wireguard-key.path;

            # To automatically create routes for everything in AllowedIPs,
            # add RouteTable=main
            RouteTable = "main";

            # FirewallMark marks all packets send and received by wg0
            # with the number 42, which can be used to define policy rules on these packets.
            FirewallMark = 42;
          };
          wireguardPeers = [
            {
              # Laptop
              PublicKey = "5KsJbcZOpbgpvevv8s346KQD5Mfro+hbf6YrfKw83BM=";
              AllowedIPs = [
                "192.168.26.2/32"
              ];

              # RouteTable can also be set in wireguardPeers
              # RouteTable in wireguardConfig will then be ignored.
              # RouteTable = 1000;
            }
            {
              # EPPD-Server
              PublicKey = "S2nYnsTrc8WUBQ01jsjL/7BZsqtAWJaKMuUToq8htj0=";
              AllowedIPs = [
                "192.168.26.3/32"
              ];

              # RouteTable can also be set in wireguardPeers
              # RouteTable in wireguardConfig will then be ignored.
              # RouteTable = 1000;
            }
            {
              # gwork
              PublicKey = "32JKbgFiIoMWBq1HE2oh3HVqDxhXbSvF10SsfDGhBHo=";
              AllowedIPs = [
                "192.168.26.4/32"
              ];

              # RouteTable can also be set in wireguardPeers
              # RouteTable in wireguardConfig will then be ignored.
              # RouteTable = 1000;
            }
          ];
        };
      };

    };

  # flake.modules.homeManager.wireguard is defined in the desktop hosts' wireguard.nix
}
