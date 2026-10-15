{
  inputs,
  ...
}:
{
  flake.modules.nixos.earth-server = {
    imports = with inputs.self.modules.nixos; [
      # Base
      system-server

      # User
      guif
      # jox

      # Settings
      apc-usp
      docker
      secrets
      systemd-boot
      wireguard
      zfs-zed
      zfs

      # Services
      immich
      matrix
      moodle
      nextcloud
      paperless
      password-pusher
      stalwart
      # stoat
      traefik
    ];

    mine.zfs.pools = [
      "truck"
      "lambo"
    ];

    age.secrets."zfs.key".file = "${inputs.self.outPath}/secrets/zfs.age";

    home-manager.users.guif = {
      imports = with inputs.self.modules.homeManager; [
        system-default
        wireguard
      ];
    };
    # home-manager.users.jox = {
    #   imports = with inputs.self.modules.homeManager; [
    #     system-default
    #   ];
    # };

    system.stateVersion = "24.05";
  };
}
