{
  inputs,
  ...
}:
{
  flake.modules.nixos.password-pusher =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      serviceName = "passwordpusher";
      volumeFolders = [ "database" ];
      secrets = config.age.secrets."passwordpusher.env".path;
      domainName = "passwords.guif.dev";
      volume = "/truck/crypt/guif/services/passwordpusher";
      version = {
        passwordpusher = "1.60.1";
        postgres = "15";
      };
    in
    {
      imports = [
        (inputs.self.factory.docker-network serviceName)
        (inputs.self.factory.docker-volume serviceName volumeFolders volume)
      ];

      age.secrets."passwordpusher.env".file = "${inputs.self.outPath}/secrets/passwordpusher.age";

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
          image = "docker.io/pglombardo/pwpush:${version.passwordpusher}";
          dependsOn = [ "${serviceName}-database" ];
          environmentFiles = [ secrets ];
          extraOptions = [
            "--network=${serviceName}"
            "--network=traefik"
          ];

          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.${serviceName}.rule" = "Host(`${domainName}`)";
          };
        };

        "${serviceName}-database" = {
          image = "docker.io/postgres:${version.postgres}";
          environmentFiles = [ secrets ];
          extraOptions = [ "--network=${serviceName}" ];
          volumes = [ "${volume}/database:/var/lib/postgresql/data" ];
        };
      };
    };
}
