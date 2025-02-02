{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-edit
    cosmic-term
    cosmic-store
    cosmic-reader
    cosmic-wallpapers
    cosmic-player
    cosmic-ext-calculator
  ];

}
