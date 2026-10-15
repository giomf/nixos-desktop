{
  inputs,
  ...
}:
let
  serviceName = "stalwart";
  domain = {
    guif = "guif.dev";
    mgarten = "mgarten.org";
    feyter = "feyter.de";
    itms = "itms.io";
  };
  volume = {
    stalwart = "/truck/crypt/guif/services/stalwart";
    traefik = "/truck/crypt/services/traefik";
  };
  version = {
    stalwart = "v0.16.26";
    certDumper = "1.8.18";
  };
in
{

  flake.modules.nixos.stalwart =
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
          "docker-${serviceName}-cert-dumper" = {
            partOf = [ "docker-${serviceName}.target" ];
            wantedBy = [ "docker-${serviceName}.target" ];
            startLimitBurst = 3;
            startLimitIntervalSec = 90;
          };
        };
      };

      virtualisation.oci-containers.containers = {
        "${serviceName}-app" = {
          image = "stalwartlabs/stalwart:${version.stalwart}";
          extraOptions = [
            "--network=${serviceName}"
            "--network=traefik"
          ];
          # environment = {
          #   STALWART_RECOVERY_MODE = "1";
          #   STALWART_RECOVERY_ADMIN = "admin:password";
          # };
          volumes = [
            "${volume.stalwart}/etc:/etc/stalwart"
            "${volume.stalwart}/data:/var/lib/stalwart"
            "${volume.stalwart}/certs:/var/lib/stalwart/certs:ro"
          ];
          labels = {
            # HTTPS
            "traefik.enable" = "true";
            "traefik.http.routers.mailserver.rule" = lib.concatStrings [
              "Host(`mail.${domain.guif}`) || "
              "Host(`autoconfig.${domain.guif}`) ||"
              "Host(`autodiscover.${domain.guif}`) || "
              "Host(`mta-sts.${domain.guif}`) || "
              "Host(`autoconfig.${domain.mgarten}`) || "
              "Host(`autodiscover.${domain.mgarten}`) || "
              "Host(`mta-sts.${domain.mgarten}`) || "
              "Host(`autoconfig.${domain.feyter}`) || "
              "Host(`autodiscover.${domain.feyter}`) || "
              "Host(`mta-sts.${domain.feyter}`) || "
              "Host(`autoconfig.${domain.itms}`) || "
              "Host(`autodiscover.${domain.itms}`) || "
              "Host(`mta-sts.${domain.itms}`)"
            ];
            "traefik.http.routers.mailserver.service" = "mailserver";
            "traefik.http.services.mailserver.loadbalancer.server.port" = "8080";

            # SMTP
            "traefik.tcp.routers.smtp.rule" = "HostSNI(`*`)";
            "traefik.tcp.routers.smtp.entrypoints" = "smtp";
            "traefik.tcp.routers.smtp.service" = "smtp";
            "traefik.tcp.services.smtp.loadbalancer.server.port" = "25";
            "traefik.tcp.services.smtp.loadbalancer.proxyProtocol.version" = "2";

            # SMTPS
            "traefik.tcp.routers.smtps.rule" = "HostSNI(`*`)";
            "traefik.tcp.routers.smtps.entrypoints" = "smtps";
            "traefik.tcp.routers.smtps.service" = "smtps";
            "traefik.tcp.routers.smtps.tls.passthrough" = "true";
            "traefik.tcp.services.smtps.loadbalancer.server.port" = "465";
            "traefik.tcp.services.smtps.loadbalancer.proxyProtocol.version" = "2";

            # IMAPS
            "traefik.tcp.routers.imaps.rule" = "HostSNI(`*`)";
            "traefik.tcp.routers.imaps.entrypoints" = "imaps";
            "traefik.tcp.routers.imaps.service" = "imaps";
            "traefik.tcp.routers.imaps.tls.passthrough" = "true";
            "traefik.tcp.services.imaps.loadbalancer.server.port" = "993";
            "traefik.tcp.services.imaps.loadbalancer.proxyProtocol.version" = "2";

            # JMAP
            # "traefik.tcp.routers.jmap.rule" = "HostSNI(`*`)";
            # "traefik.tcp.routers.jmap.service" = "jmap";
            # "traefik.tcp.routers.jmap.tls.passthrough" = "true";
            # "traefik.tcp.services.jmap.loadbalancer.server.port" = "80";
            # "traefik.tcp.services.jmap.loadbalancer.proxyProtocol.version" = "2";
          };
        };

        "${serviceName}-cert-dumper" = {
          image = "ghcr.io/kereis/traefik-certs-dumper:${version.certDumper}";
          dependsOn = [ "${serviceName}-app" ];
          extraOptions = [
            "--network=${serviceName}"
          ];
          environment = {
            OVERRIDE_UID = "2000";
            OVERRIDE_GID = "2000";
          };
          volumes = [
            "${volume.traefik}/letsencrypt:/traefik:ro"
            "${volume.stalwart}/certs/:/output/mail.guif.dev"
          ];
        };
      };
    };
}
