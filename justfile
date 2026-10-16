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

# Build and switch a remote host (earth, moon or discobox)
deploy host target=(if host == "discobox" { "guif@discobox.local" } else { host + ".guif.dev" }): (build host)
    nixos-rebuild switch --flake .\?submodules=1#{{host}} --target-host {{target}} --sudo |& nom

# Build the SD card image of a Raspberry Pi host
image host="discobox":
    nix build .\?submodules=1#nixosConfigurations.{{host}}.config.system.build.sdImage |& nom

# Flash the built image to a device, e.g. just flash /dev/sdX
flash device:
    zstdcat result/sd-image/*.img.zst | sudo dd of={{device}} bs=4M status=progress conv=fsync

# Build and show what would change vs the running system
diff: build-dry
    nix store diff-closures /run/current-system ./result

# Update flake inputs: unstable (desktops), stable (servers) or all
update channel="unstable":
    nix flake update {{ if channel == "unstable" { "nixpkgs-unstable home-manager-unstable" } else if channel == "stable" { "nixpkgs home-manager" } else if channel == "all" { "" } else { error("channel must be unstable, stable or all") } }}

# Regenerate flake.nix from flake-file inputs
write-flake:
    nix run .\?submodules=1#write-flake

#nix run github:nix-community/nixos-anywhere -- --flake .?submodules=1#<configuration> --target-host root@<ip address>
