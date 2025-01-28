{ lib, ... }:

{
  imports = [
    ../../home
    # ../../home/keyring.nix
  ];

  xdg.configFile."zellij/layouts/musmol.kdl".source = ./musmol.kdl;

  programs.ssh = {
    enable = lib.mkForce true;
    extraConfig = ''
      Host eit-buildnode1
          Hostname dehwlleitbld01
          User teameit

      Host eit-buildnode2
          Hostname dehwlleitbld02
          User teameit

      Host eit-buildnode3
          Hostname dehwlaeitbld03
          User teameit

      Host eit-buildnode4
          HostName D2295830

      Host eit-buildnode5
          HostName D2295841

      Host eit-buildnode6
          HostName D2400363

      Host eit-buildnode7
          HostName D2400364

      Host eit-buildnode8
          HostName D2400365

      Host buildhost-bart
          HostName D2347628

      Host buildhost-homer
          HostName D2347629

      Host eit-jumphost1 eit-testnode1 eit-r2d2
          Hostname D2210620

      Host eit-jumphost2 eit-testnode2 eit-c3po
          Hostname D2346756

      Host eit-jumphost-dev eit-der-dicke
          Hostname D2346034

      Host eit-*-img-1 eit-*-ci-*
          ProxyCommand ssh -W %h:%p eit-jumphost1
          StrictHostKeyChecking no
          User root

      Host eit-*-img-2
          ProxyCommand ssh -W %h:%p eit-jumphost2
          StrictHostKeyChecking no
          User root

      Host eit-*-dev-*
          ProxyCommand ssh -W %h:%p eit-jumphost-dev
          StrictHostKeyChecking no
          User root

      Host gsf-jumphost1 eit-jarjar
          Hostname D2400535

      Host gsf-gsf-img-1
          ProxyCommand ssh -W %h:%p gsf-jumphost1
          StrictHostKeyChecking no
          User root

      Host eit-*
          User E012738
    '';
  };

}
