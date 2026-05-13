{
  ...
}:
{
  flake.modules.nixos.crepo =
    { pkgs, ... }:
    let
      version = "0.5.0";
      crepo = pkgs.python3Packages.buildPythonPackage {
        pname = "crepo";
        inherit version;
        pyproject = true;

        src = builtins.fetchGit {
          url = "git@github.com:lobaro/crepo.git";
          rev = "82d222956ee319578fe522a6fd2c387b6706083d";
          ref = "refs/tags/${version}";
        };

        build-system = with pkgs.python3Packages; [
          setuptools # check your pyproject.toml
          setuptools-scm
        ];

        dependencies = with pkgs.python3Packages; [
          click
          gitpython
          python-dotenv
          termcolor
          typer
          typing-extensions
        ];

        meta = {
          description = "Management tool for c-path style apps' repos";
          mainProgram = "crepo";
        };
      };
    in
    {
      environment.systemPackages = [ crepo ];
    };
}
