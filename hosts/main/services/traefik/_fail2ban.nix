{
  ...
}:
{
  flake.modules.nixos.traefik = {
    environment.etc."fail2ban/filter.d/traefik-404.conf".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      prefregex = ^<F-MLFID>%(__prefix_line)s</F-MLFID><F-CONTENT>.+</F-CONTENT>$
      failregex = ^<HOST> \S+ \S+ \[.*?\] "\S+ \S+ HTTP/\S+" 404
      ignoreregex =
    '';

    services.fail2ban.jails.traefik-404.settings = {
      backend = "systemd";
      journalmatch = "_SYSTEMD_UNIT=docker-traefik.service";
      filter = "traefik-404";
      maxretry = 20;
      findtime = "2m";
      bantime = "24h";
    };

    environment.etc."fail2ban/filter.d/traefik-40x.conf".text = ''
      [INCLUDES]
      before = common.conf

      [Definition]
      prefregex = ^<F-MLFID>%(__prefix_line)s</F-MLFID><F-CONTENT>.+</F-CONTENT>$
      failregex = ^<HOST> \S+ \S+ \[.*?\] "\S+ \S+ HTTP/\S+" 40[13]
      ignoreregex =
    '';

    services.fail2ban.jails.traefik-40x.settings = {
      backend = "systemd";
      journalmatch = "_SYSTEMD_UNIT=docker-traefik.service";
      filter = "traefik-40x";
      maxretry = 10;
      findtime = "1h";
      bantime = "24h";
    };
  };
}
