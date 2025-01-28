{ lib, ... }:

{
  imports = [
    ../../home
    # ../../home/keyring.nix
  ];

  xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}
