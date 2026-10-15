{
  inputs,
  ...
}:

{
  flake.modules.nixos.immich =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      serviceName = "immich";
      volumeFolders = [
        "library"
        "postgres"
        "upload"
      ];
      secrets = config.age.secrets."immich.env".path;
      domainName = "fotobox.mgarten.org";
      volume = "/truck/crypt/guif/services/fotobox";
      version = {
        immich = "v3.1.0";
        postgres = "14-vectorchord0.4.3-pgvectors0.2.0";
        redis = "8.10-alpine";
      };
    in
    {

      imports = [
        (inputs.self.factory.docker-network serviceName)
        (inputs.self.factory.docker-volume serviceName volumeFolders volume)
      ];
      age.secrets."immich.env".file = "${inputs.self.outPath}/secrets/immich.age";
      systemd = {
        targets."docker-${serviceName}" = {
          wantedBy = [ "multi-user.target" ];
          startLimitBurst = 3;
          startLimitIntervalSec = 90;
        };
        services = {
          "docker-${serviceName}-app" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-machine-learning" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-database" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-redis" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
        };
      };

      virtualisation.oci-containers.containers = {
        "${serviceName}-app" = {
          image = "ghcr.io/immich-app/immich-server:${version.immich}";
          environment = {
            "DB_HOSTNAME" = "${serviceName}-database";
            "REDIS_HOSTNAME" = "${serviceName}-redis";
            "DB_DATABASE_NAME" = "immich";
          };
          volumes = [
            "/etc/localtime:/etc/localtime:ro"
            "${volume}/upload:/usr/src/app/upload:rw"
            "${volume}/library:/mnt/library:ro"
          ];
          environmentFiles = [ secrets ];
          dependsOn = [
            "${serviceName}-database"
            "${serviceName}-redis"
          ];
          extraOptions = [
            "--network=traefik"
            "--network=${serviceName}"
          ];

          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.${serviceName}.rule" = "Host(`${domainName}`)";
          };
        };

        "${serviceName}-machine-learning" = {
          image = "ghcr.io/immich-app/immich-machine-learning:${version.immich}";
          volumes = [
            "${serviceName}-cache:/cache:rw"
          ];
          extraOptions = [
            "--network=${serviceName}"
          ];
        };

        "${serviceName}-database" = {

          image = "ghcr.io/immich-app/postgres:${version.postgres}";
          environment = {
            "POSTGRES_DB" = "immich";
            "POSTGRES_INITDB_ARGS" = "--data-checksums";
          };
          volumes = [
            "${volume}/postgres:/var/lib/postgresql/data:rw"
          ];
          environmentFiles = [ secrets ];
          extraOptions = [
            "--network=${serviceName}"
          ];
        };

        "${serviceName}-redis" = {
          image = "docker.io/redis:${version.redis}";
          extraOptions = [
            "--network=${serviceName}"
          ];
        };
      };
    };
}
