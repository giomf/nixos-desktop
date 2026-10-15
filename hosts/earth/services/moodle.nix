{
  inputs,
  ...
}:
{
  flake.modules.nixos.moodle =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      serviceName = "moodle";
      volumeFolders = [
        "app"
        "data"
        "database"
      ];
      domainName = "moodle.ff-eppendorf.de";
      volume = "/truck/crypt/guif/services/moodle";
      secrets = config.age.secrets."moodle.age".path;
      version = {
        moodle = "5.0.2-debian-12-r2";
        mariadb = "11.4";
      };
    in
    {
      imports = [
        (inputs.self.factory.docker-network serviceName)
        (inputs.self.factory.docker-volume serviceName volumeFolders volume)
      ];
      age.secrets."moodle.age".file = "${inputs.self.outPath}/secrets/moodle.age";

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
          "docker-${serviceName}-database" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
        };
      };

      virtualisation.oci-containers.containers = {
        "${serviceName}-app" = {
          image = "docker.io/bitnamilegacy/moodle:${version.moodle}";
          dependsOn = [ "${serviceName}-database" ];
          environment = {
            MOODLE_DATABASE_TYPE = "mariadb";
            MOODLE_DATABASE_HOST = "${serviceName}-database";
            MOODLE_DATABASE_PORT_NUMBER = "3306";
            MOODLE_SITE_NAME = "Moodle";
            MOODLE_HOST = domainName;
            MOODLE_SSLPROXY = "yes";
            BITNAMI_DEBUG = "true";
          };
          environmentFiles = [ secrets ];
          extraOptions = [
            "--network=${serviceName}"
            "--network=traefik"
          ];
          volumes = [
            "${volume}/app:/bitnami/moodle"
            "${volume}/data:/bitnami/moodledata"
          ];
          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.${serviceName}.rule" = "Host(`${domainName}`)";
          };
        };

        "${serviceName}-database" = {
          image = "mariadb:${version.mariadb}";
          cmd = [
            "--transaction-isolation=READ-COMMITTED"
            "--log-bin=binlog"
            "--binlog-format=ROW"
            "--character-set-server=utf8mb4"
            "--collation-server=utf8mb4_unicode_ci"
          ];
          environment = {
            "MARIADB_AUTO_UPGRADE" = "true";
          };
          environmentFiles = [ secrets ];
          extraOptions = [ "--network=${serviceName}" ];
          volumes = [ "${volume}/database:/var/lib/mysql" ];
        };
      };
    };
}
