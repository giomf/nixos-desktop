#!/usr/bin/env bash

# Help function to print usage
print_help() {
    echo "Usage: $0 [command] [args]"
    echo
    echo "Commands:"
    echo "  update [stable|unstable|all] - Update specific flake inputs."
    echo "  switch                        - Switch the NixOS configuration."
    echo
    echo "Update specific flake inputs:"
    echo "  stable   - Update only the stable inputs (nixpkgs-stable, home-manager-stable, nixos-wsl)"
    echo "  unstable - Update only the unstable inputs (nixpkgs-unstable, home-manager-unstable, nixos-cosmic)"
    echo "  all      - Update all inputs"
    exit 1
}

# Check if no command was provided
if [ $# -eq 0 ]; then
    echo "Error: No command provided."
    print_help
fi

# Handle commands
case "$1" in
    update)
        if [ $# -lt 2 ]; then
            echo "Error: No argument provided for update."
            print_help
        fi

        case "$2" in
            stable)
                echo "Updating stable inputs..."
                nix flake lock --update-input nixpkgs-stable \
                                --update-input home-manager-stable \
                                --update-input nixos-wsl
                echo "Stable inputs updated."
                ;;
            unstable)
                echo "Updating unstable inputs..."
                nix flake update nixpkgs-unstable \
                                 home-manager-unstable \
                                 nixos-cosmic \
                                 nixos-hardware
                echo "Unstable inputs updated."
                ;;
            all)
                echo "Updating all inputs..."
                nix flake update
                echo "All inputs updated."
                ;;
            *)
                echo "Error: Unknown argument '$2' for update."
                print_help
                ;;
        esac
        ;;
    
    switch)
        echo "Switching NixOS configuration..."
        nh os switch .\?submodules=1
        echo "Switched configuration."
        ;;
    
    *)
        echo "Error: Unknown command '$1'."
        print_help
        ;;
esac
