{ pkgs, ... }:

{
  imports = [
    ../../home
    # ../../home/keyring.nix
  ];

  home.packages = [
    (pkgs.python313.withPackages (ppkgs: [
      ppkgs.pylint
      ppkgs.yapf
      ppkgs.mypy
      ppkgs.python-lsp-server
    ]))
  ];

  xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}
