{ inputs, ... }:
{
  # Server PublicKey: 0bJ5UDH0CRweZicO8kvIl+xp5z5Mswvfp81H5tfKOFY=
  # Client PublicKey: 5KsJbcZOpbgpvevv8s346KQD5Mfro+hbf6YrfKw83BM=
  flake.modules.nixos.wireguard =
    { config, ... }:
    {
      age.secrets.wireguard-key = {
        file = "${inputs.self.outPath}/secrets/wireguard-key.age";
      };

      # Prevent NetworkManager from managing the WireGuard interface
      networking.networkmanager.unmanaged = [ "interface:wg0" ];

      networking.wg-quick.interfaces.wg0 = {
        address = [ "192.168.26.2/32" ];
        privateKeyFile = config.age.secrets.wireguard-key.path;
        peers = [
          {
            publicKey = "0bJ5UDH0CRweZicO8kvIl+xp5z5Mswvfp81H5tfKOFY=";
            allowedIPs = [ "192.168.26.0/24" ];
            endpoint = "84.46.88.221:51820";
            persistentKeepalive = 25;
          }
        ];
      };
    };

  flake.modules.homeManager.wireguard =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ wireguard-tools ];
    };
}
