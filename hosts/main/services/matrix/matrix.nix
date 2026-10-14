{
  inputs,
  ...
}:
{

  flake.modules.nixos.matrix =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      serviceName = "matrix";
      volumeFolders = [
        "synapse"
        "synapse-database"
        "mas-database"
      ];
      baseDomainName = "guif.dev";
      domainName = "matrix.${baseDomainName}";
      volume = "/truck/crypt/guif/services/matrix";
      version = {
        caddy = "2.11-alpine";
        livekitJWT = "0.7.0";
        livekitSfu = "v1.13.7";
        masPostgres = "18-alpine";
        mas = "1.26.0";
        synapsePostgres = "18-alpine";
        synapse = "v1.162.0";
        admin = "v1.5.0";
      };
      synapseSecrets = config.age.secrets.matrix-synapse.path;
      synapseDatabaseSecrets = config.age.secrets.matrix-synapse-database.path;
      masSecrets = config.age.secrets.matrix-mas.path;
      masDatabaseSecrets = config.age.secrets.matrix-mas-database.path;
      livekitJWTSecrets = config.age.secrets.matrix-jwt.path;
      livekitSFUConfig = config.age.secrets.matrix-sfu.path;
    in
    {
      imports = [
        (inputs.self.factory.docker-network serviceName)
        (inputs.self.factory.docker-volume serviceName volumeFolders volume)
      ];
      age.secrets.matrix-synapse-database.file = "${inputs.self.outPath}/secrets/matrix-synapse-database.age";
      age.secrets.matrix-jwt.file = "${inputs.self.outPath}/secrets/matrix-jwt.age";
      age.secrets.matrix-mas = {
        file = "${inputs.self.outPath}/secrets/matrix-mas.age";
        owner = "65532";
      };
      age.secrets.matrix-mas-database.file = "${inputs.self.outPath}/secrets/matrix-mas-database.age";
      age.secrets.matrix-sfu.file = "${inputs.self.outPath}/secrets/matrix-sfu.age";
      age.secrets.matrix-synapse = {
        file = "${inputs.self.outPath}/secrets/matrix-synapse.age";
        owner = "991";
      };

      virtualisation.oci-containers.containers = {
        "${serviceName}-synapse" = {
          image = "matrixdotorg/synapse:${version.synapse}";
          dependsOn = [ "${serviceName}-synapse-database" ];
          environment = {
            SYNAPSE_CONFIG_PATH = "/homeserver.yaml";
          };
          environmentFiles = [ synapseDatabaseSecrets ];
          extraOptions = [
            "--network=${serviceName}"
            "--network=traefik"
          ];
          volumes = [
            "${volume}/synapse:/data"
            "${synapseSecrets}:/homeserver.yaml:ro"
            "${./logging.yaml}:/logging.yaml:ro"
          ];
          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.${serviceName}.rule" =
              "Host(`${domainName}`) && (PathPrefix(`/_matrix`) || PathPrefix(`/_synapse/client`) || PathPrefix(`/_synapse/admin`))";
          };
        };

        "${serviceName}-synapse-database" = {
          image = "pgautoupgrade/pgautoupgrade:${version.synapsePostgres}";
          environment = {
            # Required by Synapse: UTF8 encoding with C locale
            POSTGRES_INITDB_ARGS = "--encoding=UTF8 --locale=C";
          };
          environmentFiles = [ synapseDatabaseSecrets ];
          extraOptions = [ "--network=${serviceName}" ];
          volumes = [ "${volume}/synapse-database:/var/lib/postgresql/data" ];
        };

        "${serviceName}-livekit-jwt" = {
          image = "ghcr.io/element-hq/lk-jwt-service:${version.livekitJWT}";
          environment = {
            LIVEKIT_URL = "https://${domainName}/livekit/sfu";
            LIVEKIT_FULL_ACCESS_HOMESERVERS = "${baseDomainName}";
          };
          environmentFiles = [ livekitJWTSecrets ];
          extraOptions = [ "--network=traefik" ];
          labels =
            let
              routerName = "${serviceName}-livekit-jwt";
            in
            {
              "traefik.enable" = "true";
              "traefik.http.routers.${routerName}.rule" = "Host(`${domainName}`) && PathPrefix(`/livekit/jwt`)";
              "traefik.http.middlewares.${routerName}-strip.stripprefix.prefixes" = "/livekit/jwt";
              "traefik.http.routers.${routerName}.middlewares" = "${routerName}-strip";
            };
        };

        "${serviceName}-livekit-sfu" = {
          image = "livekit/livekit-server:${version.livekitSfu}";
          extraOptions = [ "--network=traefik" ];
          cmd = [
            "--config"
            "/etc/livekit.yaml"
          ];
          volumes = [ "${livekitSFUConfig}:/etc/livekit.yaml:ro" ];
          ports = [
            "7881:7881/tcp"
            "7882:7882/udp"
          ];
          labels =
            let
              routerName = "${serviceName}-livekit-sfu";
            in
            {
              "traefik.enable" = "true";
              "traefik.http.routers.${routerName}.rule" = "Host(`${domainName}`) && PathPrefix(`/livekit/sfu`)";
              "traefik.http.services.${routerName}.loadbalancer.server.port" = "7880";
              "traefik.http.middlewares.${routerName}-strip.stripprefix.prefixes" = "/livekit/sfu";
              "traefik.http.routers.${routerName}.middlewares" = "${routerName}-strip";
            };
        };

        "${serviceName}-mas" = {
          image = "ghcr.io/element-hq/matrix-authentication-service:${version.mas}";
          dependsOn = [ "${serviceName}-mas-database" ];
          extraOptions = [
            "--network=traefik"
            "--network=${serviceName}"
          ];
          cmd = [
            "server"
            "--config"
            "/config.yaml"
          ];
          volumes = [
            "${masSecrets}:/config.yaml:ro"
          ];
          labels =
            let
              routerName = "${serviceName}-mas-service";
            in
            {
              "traefik.enable" = "true";
              "traefik.http.routers.${routerName}.rule" =
                "Host(`${domainName}`) && (PathPrefix(`/auth`) || PathRegexp(`/_matrix/client/.+/(login|logout|refresh)`))";
              # Must be higher than synapse's auto-priority (rule string length) so MAS intercepts login/logout/refresh before synapse's /_matrix catch-all
              "traefik.http.routers.${routerName}.priority" = "200";
              # MAS serves routes at root internally; strip /auth prefix so /auth/foo → /foo
              "traefik.http.middlewares.${routerName}-strip.stripprefix.prefixes" = "/auth";
              "traefik.http.routers.${routerName}.middlewares" = "${routerName}-strip";
              "traefik.http.services.${routerName}.loadbalancer.server.port" = "8080";
            };
        };

        "${serviceName}-mas-database" = {
          image = "pgautoupgrade/pgautoupgrade:${version.masPostgres}";
          environmentFiles = [ masDatabaseSecrets ];
          extraOptions = [ "--network=${serviceName}" ];
          volumes = [ "${volume}/mas-database:/var/lib/postgresql" ];
        };

        "${serviceName}-well-known" = {
          image = "caddy:${version.caddy}";
          extraOptions = [ "--network=traefik" ];
          volumes = [
            "${./Caddyfile}:/etc/caddy/Caddyfile:ro"
          ];
          labels =
            let
              routerName = "${serviceName}-well-known";
            in
            {
              "traefik.enable" = "true";
              "traefik.http.routers.${routerName}.rule" =
                "(Host(`${domainName}`) || Host(`${baseDomainName}`)) && PathPrefix(`/.well-known`)";
              "traefik.http.services.${routerName}.loadbalancer.server.port" = "8080";
              "traefik.http.middlewares.${routerName}-cors-headers.headers.accesscontrolalloworiginlist" = "*";
              "traefik.http.middlewares.${routerName}-cors-headers.headers.accesscontrolallowmethods" =
                "GET,POST,PUT,DELETE,OPTIONS";
              "traefik.http.middlewares.${routerName}-cors-headers.headers.accesscontrolallowheaders" =
                "X-Requested-With,Content-Type,Authorization";

              "traefik.http.routers.${routerName}.middlewares" = "${routerName}-cors-headers";
            };
        };

        "${serviceName}-admin" = {
          image = "ghcr.io/etkecc/ketesa:${version.admin}";
          extraOptions = [ "--network=traefik" ];
          labels =
            let
              routerName = "${serviceName}-admin";
            in
            {
              "traefik.enable" = "true";
              "traefik.http.routers.${routerName}.rule" = "Host(`${domainName}`) && PathPrefix(`/admin`)";
              "traefik.http.services.${routerName}.loadbalancer.server.port" = "8080";
              "traefik.http.middlewares.${routerName}-slashless-redirect.redirectregex.regex" = "^(.*)(admin)$";
              "traefik.http.middlewares.${routerName}-slashless-redirect.redirectregex.replacement" = "$1$2/";
              "traefik.http.middlewares.${routerName}-strip.stripprefix.prefixes" = "/admin";
              "traefik.http.routers.${routerName}.middlewares" =
                "${routerName}-slashless-redirect,${routerName}-strip";
            };
        };
      };

      systemd = {
        targets."docker-${serviceName}" = {
          wantedBy = [ "multi-user.target" ];
          startLimitBurst = 3;
          startLimitIntervalSec = 90;
        };
        services = {
          "docker-${serviceName}-synapse" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-synapse-database" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-admin" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-livekit-jwt" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-livekit-sfu" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-authentication-service" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
          "docker-${serviceName}-authentication-service-database" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
        };
      };

    };
}
