{
  inputs,
  ...
}:
let
  serviceName = "traefik";
  generalPorts = [
    # General
    "80:80" # HTTP
    "443:443" # HTTPS
  ];
  stalwartPorts = [
    "25:25" # SMTP
    "465:465" # SMTPS
    "993:993" # IMAPS
  ];
  domainName = "traefik.guif.dev";
  volume = "/truck/crypt/services/traefik";
  version = {
    traefik = "3.7";
  };
in
{
  flake.modules.nixos.traefik =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        (inputs.self.factory.docker-network serviceName)
      ];
      age.secrets.traefik.file = "${inputs.self.outPath}/secrets/traefik.age";
      systemd = {
        targets."docker-${serviceName}" = {
          wantedBy = [ "multi-user.target" ];
          startLimitBurst = 3;
          startLimitIntervalSec = 90;
        };
        services = {
          "docker-${serviceName}" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
        };
      };

      virtualisation.oci-containers.containers = {
        "${serviceName}" = {
          image = "traefik:${version.traefik}";
          extraOptions = [ "--network=${serviceName}" ];
          ports = generalPorts ++ stalwartPorts;
          volumes = [
            "${./traefik.yml}:/traefik.yml:ro"
            "${volume}/letsencrypt:/letsencrypt"
            "${config.age.secrets.traefik.path}:/traefik-auth-secret"
            "/var/run/docker.sock:/var/run/docker.sock:ro"
          ];
          labels = {
            "traefik.enable" = "true";
            "traefik.http.routers.${serviceName}.rule" = "Host(`${domainName}`)";
            "traefik.http.routers.${serviceName}.service" = "api@internal";
            "traefik.http.routers.${serviceName}.middlewares" = "${serviceName}-auth";
            "traefik.http.middlewares.${serviceName}-auth.basicauth.usersfile" = "/traefik-auth-secret";
          };
        };
      };
    };
}
