{
  inputs,
  ...
}:
let
  hostName = "glap";
in
{
  flake.modules.nixos.${hostName} =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        system-laptop
        guif

        secrets
        systemd-boot
      ];

      home-manager.users.guif = {
        imports = with inputs.self.modules.homeManager; [
          system-laptop
          wireguard
        ];
        xdg.enable = true;
        xdg.configFile."autostart/Keepassxc.desktop".source = ./autostart/Keepassxc.desktop;

        home.packages = [
        ];
      };

      # Build aarch64 hosts (discobox)
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      system.stateVersion = "24.11";

      networking = {
        inherit hostName;
      };
    };
}
