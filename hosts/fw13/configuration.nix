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
        guif
        system-laptop
        systemd-boot
      ];

      home-manager.users.guif = {
        imports = with inputs.self.modules.homeManager; [
          system-laptop
        ];
        xdg.enable = true;
        xdg.configFile."autostart/Keepassxc.desktop".source = ./autostart/Keepassxc.desktop;

        home.packages = [
        ];
      };

      system.stateVersion = "24.11";

      networking = {
        inherit hostName;
      };
    };
}
