{
  inputs,
  ...
}:
let
  hostName = "discobox";
in
{
  flake.modules.nixos.${hostName} = {
    imports = with inputs.self.modules.nixos; [
      # Base
      system-default

      # User
      guif
    ];

    home-manager.users.guif = {
      imports = with inputs.self.modules.homeManager; [
        system-default
      ];
    };

    # Lets `just deploy discobox` switch without a TTY
    security.sudo.wheelNeedsPassword = false;

    # Reachable as discobox.local
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    system.stateVersion = "26.05";

    networking = {
      inherit hostName;
    };
  };
}
