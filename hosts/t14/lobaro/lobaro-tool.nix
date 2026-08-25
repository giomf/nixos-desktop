{
  ...
}:
{
  flake.modules.nixos.lobaro-tool =
    { pkgs, ... }:
    let
      lobaro-tool = pkgs.stdenv.mkDerivation rec {
        pname = "lobaro-tool";
        version = "2.22.0";

        src = pkgs.fetchurl {
          url = "https://github.com/lobaro/flash-tool-release/releases/download/v${version}/lobaro-tool_${version}_linux_x86_64.zip";
          sha256 = "sha256-hi3QofgJEgKUCPQwMadVxVHy21zTkRQJL+eqDjA9SKw=";
        };

        nativeBuildInputs = [
          #pkgs.autoPatchelfHook
          pkgs.unzip
        ];

        dontBuild = true;
        dontConfigure = true;

        unpackPhase = ''
          unzip $src
        '';

        installPhase = ''
          install -Dm755 lobaro-tool $out/bin/lobaro-tool
        '';
      };

    in
    {

      users = {
        users = {
          guif = {
            extraGroups = [
              "networkmanager"
              "dialout"
              # "plugdev"
            ];
          };
        };
      };

      systemd.user.services.lobaro-tool = {
        description = "Lobaro Tool";
        partOf = [ "lobaro.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${lobaro-tool}/bin/lobaro-tool";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };

      environment.systemPackages = [ lobaro-tool ];
    };
}
