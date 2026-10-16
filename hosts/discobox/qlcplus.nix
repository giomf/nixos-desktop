{
  inputs,
  ...
}:
{
  flake.modules.nixos.discobox =
    { pkgs, ... }:
    let
      # QLC+ 5.2.2 is only in unstable, back to pkgs.qlcplus with 26.11
      pkgsUnstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system};

      # Upstream ships the UART (DiscoHAT DMX) and GPIO (DiscoHAT buttons) plugins commented out
      qlcplus = pkgsUnstable.qlcplus.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [ pkgsUnstable.libgpiod ];
        postPatch = old.postPatch + ''
          substituteInPlace plugins/CMakeLists.txt \
            --replace-fail '#    add_subdirectory(uart)' 'add_subdirectory(uart)' \
            --replace-fail '#    add_subdirectory(gpio)' 'add_subdirectory(gpio)'
        '';
      });
    in
    {
      environment.systemPackages = [ qlcplus ];

      users = {
        users.qlcplus = {
          isSystemUser = true;
          group = "qlcplus";
          extraGroups = [
            "dialout"
            "gpio"
          ];
          home = "/var/lib/qlcplus";
        };
        groups.qlcplus = { };
        groups.gpio = { };
      };

      services.udev.extraRules = ''
        SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"
      '';

      # Headless QML UI, controlled through the v5 web interface on :9999.
      # Like upstream's qlcplus-start.sh, opens the project set as autostart in the web interface.
      systemd.services.qlcplus = {
        description = "QLC+ lighting controller";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        environment = {
          QT_QPA_PLATFORM = "offscreen";
          QT_QUICK_BACKEND = "software";
        };
        script = ''
          if [ -e .qlcplus/autostart.qxw ]; then
            set -- .qlcplus/autostart.qxw
          fi
          exec ${qlcplus}/bin/qlcplus-qml --nowm --no3d --web "$@"
        '';
        serviceConfig = {
          User = "qlcplus";
          Group = "qlcplus";
          # The web interface saves autostart.qxw to ~/.qlcplus
          StateDirectory = "qlcplus qlcplus/.qlcplus";
          WorkingDirectory = "/var/lib/qlcplus";
          Restart = "on-failure";
        };
      };

      networking.firewall.allowedTCPPorts = [ 9999 ];
    };
}
