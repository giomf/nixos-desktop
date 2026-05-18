let
  fw13 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGyA0YMlOsOS7837MPi8ocaS5mf8IwNoX741yey+5gGF";
  guif = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIPI4hVcnH2C5Rq0Pkgv+rw2h1dAm2QQdyboDfW7kUlw";
  all = [
    fw13
    guif
  ];
in
{
  "wireguard-key.age".publicKeys = all;
}
