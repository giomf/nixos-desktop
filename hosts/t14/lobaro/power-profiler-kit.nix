{
  ...
}:
{
  flake.modules.nixos.power-profiler-kit =
    { pkgs, ... }:
    let
      version = "1.0.1";
      power-profiler-kit = pkgs.python3Packages.buildPythonPackage {
        pname = "lob-ppk";
        inherit version;
        pyproject = true;

        src = builtins.fetchGit {
          url = "git@github.com:lobaro/python-lob-ppk.git";
          rev = "6b9a844b93d2185c8b0623734587458d119dbe88";
          ref = "refs/tags/${version}";
        };

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
      systemd.user.services.power-profiler-kit = {
        description = "Power Profiler Kit";
        partOf = [ "lobaro.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${power-profiler-kit}/bin/lob-ppk-tool";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      environment.systemPackages = [ power-profiler-kit ];
    };
}
