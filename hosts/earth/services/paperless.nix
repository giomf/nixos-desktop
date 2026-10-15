{
  inputs,
  ...
}:
{
  flake.modules.nixos.paperless =
    {
      config,
      lib,
      pkgs,
      ...
    }:

    let
      serviceName = "paperless";
      volumeFolders = [
        "data"
        "media"
        "consume"
        "export"
      ];
      domainName = "documents.guif.dev";
      volume = "/truck/crypt/guif/services/paperless";
      secrets = config.age.secrets."paperless.age".path;
      version = {
        paperless = "3.3.0";
        redis = "8.10";
      };
    in
    {
      imports = [
        (inputs.self.factory.docker-network serviceName)
        (inputs.self.factory.docker-volume serviceName volumeFolders volume)
      ];
      age.secrets."paperless.age".file = "${inputs.self.outPath}/secrets/paperless.age";

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
          image = "ghcr.io/paperless-ngx/paperless-ngx:${version.paperless}";
          dependsOn = [ "${serviceName}-redis" ];
          environment = {
            PAPERLESS_REDIS = "redis://${serviceName}-redis:6379";
            PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://${domainName}";
            PAPERLESS_ALLOWED_HOSTS = "${domainName}";
            PAPERLESS_USE_X_FORWARD_HOST = "true";
          };
          environmentFiles = [ secrets ];
          extraOptions = [
            "--network=${serviceName}"
            "--network=traefik"
          ];
          volumes = [
            "${volume}/data:/usr/src/paperless/data"
            "${volume}/media:/usr/src/paperless/media"
            "${volume}/export:/usr/src/paperless/export"
            "${volume}/consume:/usr/src/paperless/consume"
          ];

          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.${serviceName}.rule" = "Host(`${domainName}`)";
          };
        };

        "${serviceName}-redis" = {
          image = "docker.io/library/redis:${version.redis}";
          extraOptions = [ "--network=${serviceName}" ];
        };
      };
    };
}
