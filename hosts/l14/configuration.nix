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
        systemd-boot
      ];

      home-manager.users.guif = {
        imports = with inputs.self.modules.homeManager; [
          system-laptop
        ];
        xdg.enable = true;
        xdg.configFile."autostart/Keepassxc.desktop".source = ./autostart/Keepassxc.desktop;
        home.packages = [
          pkgs.github-copilot-cli
        ];
      };

      system.stateVersion = "24.11";

      networking = {
        inherit hostName;
      };
    };
}
