[private]
build-dry:
    nixos-rebuild dry-build --flake .\?submodules=1 |& nom

# Build a host (defaults to this machine)
build host=`hostname`:
    nixos-rebuild build --flake .\?submodules=1#{{host}} |& nom

test:
    sudo nixos-rebuild test --flake .\?submodules=1 |& nom

# Switch this machine
switch:
    sudo nixos-rebuild switch --flake .\?submodules=1 |& nom

# Build a host on guif.dev (defaults to this machine)
build-remote host=`hostname`:
    nixos-rebuild build --flake .\?submodules=1#{{host}} --build-host guif.dev --use-substitutes |& nom

# Build and switch a server (earth or moon)
deploy host: (build host)
    nixos-rebuild switch --flake .\?submodules=1#{{host}} --target-host {{host}}.guif.dev --sudo |& nom

# Build and show what would change vs the running system
diff: build-dry
    nix store diff-closures /run/current-system ./result

# Update all inputs
update:
    nix flake update

# Update the stable channel (servers)
update-stable:
    nix flake update nixpkgs home-manager

# Update the unstable channel (desktops)
update-unstable:
    nix flake update nixpkgs-unstable home-manager-unstable

# Regenerate flake.nix from flake-file inputs
write-flake:
    nix run .\?submodules=1#write-flake

#nix run github:nix-community/nixos-anywhere -- --flake .?submodules=1#<configuration> --target-host root@<ip address>
