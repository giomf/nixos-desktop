{
  pkgs,
  ...
}:
{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      font-awesome
      (nerdfonts.override {
        fonts = [
          "NerdFontsSymbolsOnly"
          "FiraCode"
        ];
      })
      noto-fonts
      noto-fonts-emoji

      roboto # Used for tpyst cv
      source-sans-pro # Used for typst cv
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = [ "Noto Color Emoji" ];
        monospace = [ "Noto Sans Mono" ];
        sansSerif = [ "Noto Sans" ];
        serif = [ "Noto Serif" ];
      };
    };
  };
}
