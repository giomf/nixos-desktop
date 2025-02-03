# Switch NixOS configuration
switch:
    nh os switch .\?submodules=1

build-remote:
    nixos-rebuild build --flake .\?submodules=1 --build-host guif.dev --use-substitutes |& nom 

# Update stable inputs
update-stable:
    nix flake update nixpkgs-stable \
                     home-manager-stable \
                     nixos-wsl

# Update unstable inputs
update-unstable:
    nix flake update nixpkgs-unstable \
                     home-manager-unstable \
                     nixos-cosmic \
                     nixos-hardware

# Update all inputs
update-all:
    nix flake update
