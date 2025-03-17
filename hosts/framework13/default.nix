{
  pkgs,
  ...
}:

{
  imports = [
    ../common.nix
    # ./greetd.nix
    ./steam.nix
    ./disko-config.nix
    ./hardware-configuration.nix
    ./cosmic.nix
  ];

  # home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.guif = ./home.nix;

  system.stateVersion = "24.11";

  boot = {
    kernelParams = [ "quiet" ];
    initrd = {
      systemd.enable = true;
    };
    plymouth.enable = true;
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };
    # Allow building img for pi
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  # Allow wayland support in all chrome and most electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # environment.systemPackages = with pkgs; [ ];
  # environment.defaultPackages = with pkgs; [ ];

  xdg.portal = {
    config.common.default = "*";
    enable = true;
    wlr.enable = true;
  };

  programs = {
    # Needed for backlight controll as non root
    light.enable = true;
    virt-manager.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  # Security
  security = {
    pam.services.swaylock = { };
    # Enable sound
    rtkit.enable = true;
  };

  # Services
  services = {
    printing = {
      enable = true;
      drivers = [
        pkgs.brlaser
      ];
    };
    # blueman.enable = true;
    fwupd.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # Not needed for fw13: https://community.frame.work/t/guide-fw13-ryzen-power-management/42988
    # auto-cpufreq.enale = true:
    upower.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  # User
  users.users.guif = {
    extraGroups = [
      "video"
      "audio"
      "networkmanager"
      "libvirtd"
      "dialout"
      "wireshark"
    ];
  };

  # Networking
  networking = {
    hostName = "glap";
    networkmanager.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    # graphics = {
    #   enable = true;
    # };
  };
}
