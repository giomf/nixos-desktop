{
  inputs,
  ...
}:
{
  flake.modules.nixos.lobaro =
    { pkgs, ... }:
    {
      systemd.user.targets.lobaro = {
        description = "Lobaro tool suite";
        wants = [
          "lobaro-tool.service"
          "power-profiler-kit.service"
        ];
      };

      # Needed for jlink
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.segger-jlink.acceptLicense = true;
      nixpkgs.config.permittedInsecurePackages = [
        "segger-jlink-qt4-874"
      ];
      services.udev.packages = with pkgs; [
        segger-jlink
        nrf-udev
      ];

      imports = with inputs.self.modules.nixos; [
        crepo
        lobaro-tool
        power-profiler-kit
      ];

    };
}
