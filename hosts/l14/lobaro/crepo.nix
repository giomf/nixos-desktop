{
  ...
}:
{
  flake.modules.nixos.crepo =
    { pkgs, ... }:
    let
      version = "0.4.2";
      crepo = pkgs.python3Packages.buildPythonPackage {
        pname = "crepo";
        inherit version;
        pyproject = true;

        src = builtins.fetchGit {
          url = "git@github.com:lobaro/crepo.git";
          rev = "85e369095adf4cfc1f328a23bd6d951ef87ca78b";
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
