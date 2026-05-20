let
  fw13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyA0YMlOsOS7837MPi8ocaS5mf8IwNoX741yey+5gGF";
  t14 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+Iz2Ho2ZajEmM+BOEObmJQTGICjaUER0oWA2TJpw8k";
  guif = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw";
in
{
  "wireguard-fw13-key.age".publicKeys = [
    guif
    fw13
  ];
  "wireguard-t14-key.age".publicKeys = [
    guif
    t14
  ];
}
