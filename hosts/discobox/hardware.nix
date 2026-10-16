{
  inputs,
  ...
}:

{
  flake.modules.nixos.discobox =
    {
      lib,
      modulesPath,
      pkgs,
      ...
    }:
    let
      # The vendor kernel is not in any binary cache and takes hours under binfmt, so cross-compile it
      pkgsCross = import inputs.nixpkgs {
        localSystem = "x86_64-linux";
        crossSystem = "aarch64-linux";
      };
    in
    {
      imports = [
        (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
        inputs.nixos-hardware.nixosModules.raspberry-pi-3
      ];

      nixpkgs.hostPlatform = "aarch64-linux";

      boot.kernelPackages = pkgsCross.linuxPackagesFor (
        pkgsCross.callPackage "${inputs.nixos-hardware}/raspberry-pi/common/kernel.nix" {
          rpiVersion = 3;
          # Kernel Rust would cross-build rustc and bindgen, nothing on this box needs it
          argsOverride.kernelPatches = with pkgsCross.kernelPatches; [
            bridge_stp_helper
            request_key_helper
            {
              name = "no-rust";
              patch = null;
              structuredExtraConfig.RUST = lib.mkForce lib.kernel.no;
            }
          ];
        }
      );

      # Pulled in by the sd-image profile, would build a zfs module for the vendor kernel
      boot.supportedFilesystems.zfs = lib.mkForce false;

      # ttyAMA0 drives the DiscoHAT DMX output, so no kernel console or getty on it
      boot.kernelParams = lib.mkForce [ "console=tty0" ];

      hardware.raspberry-pi = {
        # Firmware chainloads U-Boot and keeps its config.txt overlays in the dtb U-Boot boots,
        # the activation script rewrites the firmware partition on every switch
        firmware = {
          enable = true;
          uboot.enable = true;
          # Release built from the same commit as the kernel above (extra/git_hash), keep both in sync
          package = pkgs.raspberrypifw.overrideAttrs rec {
            version = "1.20260915";
            src = pkgs.fetchFromGitHub {
              owner = "raspberrypi";
              repo = "firmware";
              rev = version;
              hash = "sha256-vZxjq5icaVdlQUn5saJhJskW59xxr8IBO9iRULO6ppg=";
            };
          };
        };
        # Moves the PL011 (ttyAMA0) from Bluetooth to GPIO14/15 for the DiscoHAT
        configtxt.deviceTreeOverlays.all = [ { disable-bt = { }; } ];
      };
    };
}
