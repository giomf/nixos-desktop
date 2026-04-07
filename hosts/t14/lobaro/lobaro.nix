{
  inputs,
  ...
}:
{
  flake.modules.nixos.lobaro = {
    systemd.user.targets.lobaro = {
      description = "Lobaro tool suite";
      wants = [
        "lobaro-tool.service"
        "power-profiler-kit.service"
      ];
    };

    imports = with inputs.self.modules.nixos; [
      crepo
      lobaro-tool
      power-profiler-kit
    ];

  };
}
