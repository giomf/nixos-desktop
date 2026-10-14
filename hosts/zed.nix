{ inputs, ... }:
{
  flake.modules.nixos.zfs-zed =
    { pkgs, config, ... }:
    {
      age.secrets."lineareal-admin-email-password".file =
        "${inputs.self.outPath}/secrets/lineareal-admin-email-password.age";

      programs.msmtp = {
        enable = true;
        defaults = {
          auth = true;
          tls = true;
          tls_starttls = false;
        };
        accounts.default = {
          host = "w0133bc5.kasserver.com";
          port = 465;
          from = "admin@lineareal.de";
          user = "admin@lineareal.de";
          passwordeval = "cat ${config.age.secrets.lineareal-admin-email-password.path}";
        };
      };

      services.zfs.zed = {
        settings = {
          ZED_EMAIL_ADDR = [ "admin@lineareal.de" ];
          ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
          ZED_EMAIL_OPTS = "@ADDRESS@";
          ZED_NOTIFY_INTERVAL_SECS = 3600;
          ZED_NOTIFY_VERBOSE = true;
        };
        enableMail = true;
      };
    };
}
