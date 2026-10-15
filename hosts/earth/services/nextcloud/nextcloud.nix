{
  inputs,
  ...
}:

{
  flake.modules.nixos.nextcloud =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      serviceName = "nextcloud";
      databaseSecret = config.age.secrets.nextcloud-database.path;
      domainName = "cloud.lineareal.de";
      volume = {
        app = "/truck/crypt/lineareal/services/nextcloud/app";
        database = "/lambo/crypt/lineareal/services/nextcloud/database";
        data = "/truck/crypt/lineareal/services/nextcloud/data";
        redis = "/truck/crypt/lineareal/services/nextcloud/redis";
        logs = "/lambo/crypt/lineareal/services/nextcloud/logs";
        uploads = "/truck/crypt/lineareal/services/nextcloud/uploads";
      };
      version = {
        nextcloud = "34.0.4-fpm";
        mariadb = "12.3";
        nginx = "1.31";
        redis = "8.10-alpine";
      };
    in
    {
      imports = [
        (inputs.self.factory.docker-network serviceName)
      ];
      age.secrets.nextcloud-database.file = "${inputs.self.outPath}/secrets/nextcloud-database.age";

      systemd = {
        targets."docker-${serviceName}" = {
          wantedBy = [ "multi-user.target" ];
          startLimitBurst = 3;
          startLimitIntervalSec = 90;
        };
        services = {
          "docker-${serviceName}-frontend" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-backend" = {
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
          "docker-${serviceName}-cron" = {
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

        "${serviceName}-frontend" = {
          image = "nginx:${version.nginx}";
          dependsOn = [ "${serviceName}-backend" ];
          extraOptions = [
            "--network=${serviceName}"
            "--network=traefik"
          ];
          volumes = [
            "${volume.app}:/var/www/html:ro"
            "${./nginx.conf}:/etc/nginx/nginx.conf:ro"
          ];
          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.${serviceName}.rule" = "Host(`${domainName}`)";
            "traefik.http.routers.${serviceName}.middlewares" = "${serviceName}-headers";
            "traefik.http.middlewares.${serviceName}-headers.headers.stsSeconds" = "15552000";
            "traefik.http.middlewares.${serviceName}-headers.headers.stsIncludeSubdomains" = "true";
            "traefik.http.middlewares.${serviceName}-headers.headers.stsPreload" = "true";
            "traefik.http.middlewares.${serviceName}-headers.headers.forceSTSHeader" = "true";
          };
        };

        "${serviceName}-backend" = {
          image = "nextcloud:${version.nextcloud}";
          dependsOn = [ "${serviceName}-database" ];
          extraOptions = [ "--network=${serviceName}" ];
          volumes = [
            "${volume.app}:/var/www/html"
            "${volume.data}:/var/www/data"
            "${volume.logs}:/var/www/logs"
            "${volume.uploads}:/var/www/uploads"
            "${./temp_upload_dir.ini}:/usr/local/etc/php/conf.d/temp_upload_dir.ini:ro"
            "${./php-fpm.conf}:/usr/local/etc/php-fpm.d/zz-nextcloud.conf:ro"
          ];
        };

        "${serviceName}-database" = {
          image = "mariadb:${version.mariadb}";
          cmd = [
            "--transaction-isolation=READ-COMMITTED"
          ];
          environmentFiles = [ databaseSecret ];
          environment = {
            # Upgrade system tables when starting
            "MARIADB_AUTO_UPGRADE" = "true";
          };
          extraOptions = [ "--network=${serviceName}" ];
          volumes = [ "${volume.database}:/var/lib/mysql" ];
        };

        "${serviceName}-cron" = {
          image = "nextcloud:${version.nextcloud}";
          dependsOn = [
            "${serviceName}-backend"
            "${serviceName}-database"
          ];
          entrypoint = "/cron.sh";
          extraOptions = [ "--network=${serviceName}" ];
          volumes = [
            "${volume.app}:/var/www/html"
            "${volume.data}:/var/www/data"
            "${volume.logs}:/var/www/logs"
            "${volume.uploads}:/var/www/uploads"
          ];
        };

        "${serviceName}-redis" = {
          image = "redis:${version.redis}";
          extraOptions = [ "--network=${serviceName}" ];
          cmd = [
            "redis-server"
            "/redis.conf"
          ];
          volumes = [
            # Needed because I dont know why redis would not accept requirepass in the ENV via REDIS_ARGS
            "${volume.redis}/redis.conf:/redis.conf"
          ];
        };
      };
    };
}
