{
  ...
}:
{
  flake.modules.nixos.power-profiler-kit =
    { pkgs, ... }:
    let
      version = "1.0.0";
      power-profiler-kit = pkgs.python3Packages.buildPythonPackage {
        pname = "power-profiler-kit";
        inherit version;
        pyproject = true;

        src = builtins.fetchGit {
          url = "git@github.com:lobaro/python-lob-ppk.git";
          rev = "13796f2c5604d5de100d889e1b83cd4adff50515";
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
