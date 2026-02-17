# Switch NixOS configuration
build:
    nixos-rebuild build --flake .\?submodules=1 |& nom 

switch: build
    sudo nixos-rebuild switch --flake .\?submodules=1 |& nom 


build-remote:
    nixos-rebuild build --flake .\?submodules=1 --build-host guif.dev --use-substitutes |& nom 

# Update all inputs
update:
    nix flake update
