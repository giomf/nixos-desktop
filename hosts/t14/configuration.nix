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
        home.packages = with pkgs; [
          bambu-studio
        ];
      };

      system.stateVersion = "24.11";

      # Fix for AMDGPU MES hang on Krackan (Radeon 840M/860M), requires kernel >= 6.19.10
      # https://gitlab.freedesktop.org/drm/amd/-/issues/4749
      # Fallback workaround if kernel fix is not working: amdgpu.mes=0
      # boot.kernelParams = [ "amdgpu.mes=0" ];
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking = {
        inherit hostName;
      };
    };
}
