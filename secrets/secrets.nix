let
  fw13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyA0YMlOsOS7837MPi8ocaS5mf8IwNoX741yey+5gGF";
  t14 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+Iz2Ho2ZajEmM+BOEObmJQTGICjaUER0oWA2TJpw8k";
  earth = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICboH9u2FM08E+E+3NzYE7+1pm+RyfBMvHfmR1XNun1V";
  moon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClkuNfZkYdC9mTajfG5O4hJuCuL/C+xOXWaOg75CbM0";
  guif = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw";
in
{
  # Desktops
  "wireguard-fw13-key.age".publicKeys = [
    guif
    fw13
  ];
  "wireguard-t14-key.age".publicKeys = [
    guif
    t14
  ];

  # Servers
  "immich.age".publicKeys = [
    earth
    guif
  ];
  "lineareal-admin-email-password.age".publicKeys = [
    earth
    moon
    guif
  ];
  "matrix-mas-database.age".publicKeys = [
    earth
    guif
  ];
  "matrix-synapse-database.age".publicKeys = [
    earth
    guif
  ];
  "matrix-synapse.age".publicKeys = [
    earth
    guif
  ];
  "matrix-mas.age".publicKeys = [
    earth
    guif
  ];
  "matrix-jwt.age".publicKeys = [
    earth
    guif
  ];
  "matrix-sfu.age".publicKeys = [
    earth
    guif
  ];
  "moodle.age".publicKeys = [
    earth
    guif
  ];
  "nextcloud-database.age".publicKeys = [
    earth
    guif
  ];
  "paperless.age".publicKeys = [
    earth
    guif
  ];
  "passwordpusher.age".publicKeys = [
    earth
    guif
  ];
  "stoat.age".publicKeys = [
    earth
    guif
  ];
  "traefik.age".publicKeys = [
    earth
    guif
  ];
  "wireguard-key.age".publicKeys = [
    earth
    guif
  ];
  "zfs.age".publicKeys = [
    earth
    guif
  ];
}
