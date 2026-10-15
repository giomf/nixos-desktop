{
  ...
}:
{
  flake.factory = {
    docker-network =
      serviceName:
      { pkgs, ... }:
      {
        systemd.services."docker-${serviceName}-network" = {
          path = [ "${pkgs.docker}" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStop = "docker network rm -f ${serviceName}";
          };
          partOf = [ "docker-${serviceName}.target" ];
          wantedBy = [ "docker-${serviceName}.target" ];
          script = ''
            if docker network inspect ${serviceName}; then
              echo "Network ${serviceName} already exists."
            else
              echo "Creating ${serviceName} network"
              docker network create ${serviceName}
            fi
          '';
        };
      };

    docker-volume =
      serviceName: volumeFolders: volume:
      { lib, ... }:
      {
        systemd.services."docker-${serviceName}-volume-init" =
          let
            paths = lib.strings.concatStringsSep " " (
              builtins.map (x: ''"'' + volume + "/" + x + ''"'') volumeFolders
            );
          in
          {
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            script = ''
              declare -ar DIRECTORIES=(${paths})

              echo "Creating needed directory structure in ${volume}"
              for i in "''${DIRECTORIES[@]}"; do
                if [[ -d "''${i}" ]]; then
                  echo "$i already exists. Aborting!"
                else
                  mkdir -p -v "''${i}"
                fi
              done
            '';
          };
      };
    nixos-builder =
      target: repository: onCalender:
      { pkgs, ... }:
      {
        # Define the systemd service
        systemd.services."nixos-builder-${target}" = {
          description = "NixOs Builder for ${target}";

          serviceConfig = {
            Type = "oneshot";
            WorkingDirectory = "/var/tmp";
            ExecStart = "${pkgs.writeShellScript "build-script" ''
              set -euo pipefail

              WORK_DIR="/var/tmp/nixos-builder"
              mkdir -p "$WORK_DIR"
              cd "$WORK_DIR"
              REPO_DIR=$(basename ${repository} .git)

              echo "Initializing build..."

               # Clone or pull repository with submodules
              if [ -d "$REPO_DIR" ]; then
                echo "Repository exists, pulling latest updates..."
                cd "$REPO_DIR"
                git fetch -a
                git reset --hard origin/main
                git submodule update --recursive --remote
                echo "Update flake..."
                nix flake update
              else
                echo "Cloning repository with submodules..."
                git clone --recurse-submodules ${repository}
                cd $REPO_DIR
              fi
              echo "Start building ${target} in $REPO_DIR at $(date)"
              nixos-rebuild-ng --max-jobs 4 --cores 16 build --flake .\?submodules=1#${target}
              echo "Build finished successfully at $(date)"
            ''}";
          };

          path = with pkgs; [
            bash
            git
            nix
            nixos-rebuild-ng
            openssh
          ];

          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];
        };

        systemd.timers."nixos-builder-${target}" = {
          description = "Timer for ${target}";
          wantedBy = [ "timers.target" ];

          timerConfig = {
            OnCalendar = "${onCalender}";
            Unit = "nixos-builder-${target}.service";
          };

        };
      };
  };
}
