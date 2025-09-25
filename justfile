# Switch NixOS configuration
build:
    nh os build .\?submodules=1

switch: build
    nh os switch .\?submodules=1

build-remote:
    nixos-rebuild-ng build --flake .\?submodules=1 --build-host guif.dev --use-substitutes |& nom 

# Update all inputs
update:
    nix flake update
