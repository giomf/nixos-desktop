{
  inputs,
  ...
}:
let
  hostName = "gwork";
in
{
  flake.modules.nixos.${hostName} =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        system-laptop

        lobaro
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
        home.packages = with pkgs; [
          bambu-studio
        ];
      };

      system.stateVersion = "24.11";

      networking = {
        inherit hostName;
      };
    };
}
