let
  fw13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyA0YMlOsOS7837MPi8ocaS5mf8IwNoX741yey+5gGF";
  t14 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+Iz2Ho2ZajEmM+BOEObmJQTGICjaUER0oWA2TJpw8k";
  main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICboH9u2FM08E+E+3NzYE7+1pm+RyfBMvHfmR1XNun1V";
  backup = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIClkuNfZkYdC9mTajfG5O4hJuCuL/C+xOXWaOg75CbM0";
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
    main
    guif
  ];
  "lineareal-admin-email-password.age".publicKeys = [
    main
    backup
    guif
  ];
  "matrix-mas-database.age".publicKeys = [
    main
    guif
  ];
  "matrix-synapse-database.age".publicKeys = [
    main
    guif
  ];
  "matrix-synapse.age".publicKeys = [
    main
    guif
  ];
  "matrix-mas.age".publicKeys = [
    main
    guif
  ];
  "matrix-jwt.age".publicKeys = [
    main
    guif
  ];
  "matrix-sfu.age".publicKeys = [
    main
    guif
  ];
  "moodle.age".publicKeys = [
    main
    guif
  ];
  "nextcloud-database.age".publicKeys = [
    main
    guif
  ];
  "paperless.age".publicKeys = [
    main
    guif
  ];
  "passwordpusher.age".publicKeys = [
    main
    guif
  ];
  "stoat.age".publicKeys = [
    main
    guif
  ];
  "traefik.age".publicKeys = [
    main
    guif
  ];
  "wireguard-key.age".publicKeys = [
    main
    guif
  ];
  "zfs.age".publicKeys = [
    main
    guif
  ];
}
