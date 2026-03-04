{
  inputs,
  ...
}:
{
  flake.modules.nixos.lobaro = {
    imports = with inputs.self.modules.nixos; [
      lobaro-tool
      power-profiler-kit
    ];

  };
}
