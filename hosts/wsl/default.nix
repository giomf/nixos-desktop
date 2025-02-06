{ ... }:

{
  imports = [
    ../common.nix
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.guif = ./home.nix;

  system.stateVersion = "23.05";

  system.activationScripts.bin-bash-hack = {
    text = ''
      	[[ ! -f /bin/bash ]] && ln -s /run/current-system/sw/bin/bash /bin/bash
      	[[ ! -f /usr/bin/perl ]] && ln -s /run/current-system/sw/bin/perl /usr/bin/perl
    '';
  };

  wsl = {
    enable = true;
    defaultUser = "guif";
    startMenuLaunchers = true;
    wslConf = {
      automount.root = "/mnt";
      network.generateHosts = false;
    };
  };

  virtualisation.docker = {
    enable = true;
  };

  networking.hostName = "wsl";

  boot = {
    # Allow building img for pi
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  wsl.interop.register = true;
}
