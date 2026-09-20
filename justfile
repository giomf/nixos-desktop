# Switch NixOS configuration
[private]
build-dry:
    nixos-rebuild dry-build --flake .\?submodules=1 |& nom 

build:
    nixos-rebuild build --flake .\?submodules=1 |& nom 

test:
    sudo nixos-rebuild test --flake .\?submodules=1 |& nom 

switch:
    sudo nixos-rebuild switch --flake .\?submodules=1 |& nom 

build-remote:
    nixos-rebuild build --flake .\?submodules=1 --build-host guif.dev --use-substitutes |& nom

# Preview what would be built/fetched, without building anything

# Build and show what would change vs the running system
diff: build-dry
    nix store diff-closures /run/current-system ./result

# Update all inputs
update:
    nix flake update

#nix run github:nix-community/nixos-anywhere -- --flake .?submodules=1#<configuration> --target-host root@<ip address>
