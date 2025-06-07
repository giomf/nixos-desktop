{ pkgs, ... }:

{
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  services.gnome.gnome-keyring.enable = false;
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-player
    cosmic-term
    cosmic-wallpapers
    cosmic-edit
  ];
}
