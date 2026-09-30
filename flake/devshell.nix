{ inputs, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  debug = true;
  systems = [
    "x86_64-linux"
  ];

  perSystem =
    { pkgs, system, ... }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          inputs.agenix.packages.${system}.default
          just
          nixos-rebuild-ng
          nix-output-monitor
        ];
      };
    };
}
