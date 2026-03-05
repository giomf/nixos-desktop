{
  inputs,
  ...
}:
{
  flake.modules.nixos.lobaro = {
    imports = with inputs.self.modules.nixos; [
      crepo
      lobaro-tool
      power-profiler-kit
    ];

  };
}
