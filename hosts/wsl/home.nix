{ pkgs, ... }:

{
  imports = [
    ../../home
    # ../../home/keyring.nix
  ];

  home.packages = [
    (pkgs.python313.withPackages (ppkgs: [
      ppkgs.jedi-language-server
      ppkgs.mypy
      ppkgs.pylint
      ppkgs.python-lsp-ruff
      ppkgs.python-lsp-server
      ppkgs.ruff
      ppkgs.yapf
    ]))
  ];

  xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;
}
