{
  ...
}:
{
  flake.modules.nixos.power-profiler-kit =
    { pkgs, ... }:
    let
      version = "0.0.3";
      power-profiler-kit = pkgs.python3Packages.buildPythonPackage {
        pname = "power-profiler-kit";
        inherit version;

        src = builtins.fetchGit {
          url = "git@github.com:lobaro/python-lob-ppk.git";
          rev = "90882c77170ca5fb4df26e218c4c22030e9ec73d";
          ref = "refs/tags/${version}";
        };

        pyproject = true;

        build-system = with pkgs.python3Packages; [
          setuptools # check your pyproject.toml
          setuptools-scm
        ];

        dependencies = with pkgs.python3Packages; [
          pyserial
          ppk2-api
        ];

        meta = {
          description = "Power Profiler Kit";
          mainProgram = "power-profiler-kit";
        };
      };
    in
    {
      environment.systemPackages = [ power-profiler-kit ];
    };
}
