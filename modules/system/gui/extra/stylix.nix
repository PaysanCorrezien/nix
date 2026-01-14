{
  lib,
  config,
  pkgs,
  ...
}:
let
  # Determine if stylix should be enabled based on GUI being enabled and not using niri
  # This avoids checking config.settings inside mkIf which can cause infinite recursion
  isServer = config.settings.isServer or false;
  isWSL = config.wsl.enable or false;
  windowManager = config.settings.windowManager or null;
  shouldEnableStylix = !(isServer || isWSL) && windowManager != "niri" && windowManager != null;
in
{
  config = {
    # Configure stylix based on computed value
    stylix = if shouldEnableStylix then {
      enable = true;
      image = ../../../../.wallpaper.png;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
      opacity = {
        applications = 0.9;
        terminal = 0.9;
        desktop = 0.9;
        popups = 0.9;
      };
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
        serif = {
          package = pkgs.noto-fonts;
          name = "Noto Serif";
        };
        sansSerif = {
          package = pkgs.noto-fonts;
          name = "Noto Sans";
        };
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
      };
      cursor = {
        package = pkgs.rose-pine-cursor;
        name = "Rose-Pine-Cursor";
        size = 24;
      };
      targets = {
        gtk.enable = true;
        grub.useImage = true;
        nixos-icons.enable = true;
      };
    } else {
      enable = false;
    };

    environment.systemPackages = lib.mkIf shouldEnableStylix (with pkgs; [
      rose-pine-icon-theme
      rose-pine-cursor
    ]);
  };
}
