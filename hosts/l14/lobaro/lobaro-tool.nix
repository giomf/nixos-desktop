{
  ...
}:
{
  flake.modules.nixos.lobaro-tool =
    { pkgs, ... }:
    let
      lobaro-tool = pkgs.stdenv.mkDerivation rec {
        pname = "lobaro-tool";
        version = "2.19.0";

        src = pkgs.fetchurl {
          url = "https://github.com/lobaro/flash-tool-release/releases/download/v${version}/lobaro-tool_2.19.0_linux_x86_64.zip";
          sha256 = "sha256-eKoCbIfh2CZ+g06s4Zi3oyC5nNieKCF3KxSS8yAwzro=";
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

      environment.systemPackages = [ lobaro-tool ];
    };
}
