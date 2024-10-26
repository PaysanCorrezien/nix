{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.settings.stylix = lib.mkOption {
    type = lib.types.submodule {
      options.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };

  config = lib.mkMerge [
    {
      settings.stylix.enable = config.settings.gui.enable;
    }
    (lib.mkIf config.settings.stylix.enable {
      stylix = {
        enable = true;
        image = ../../../../modules/home-manager/gnome/backgrounds/wallpaper_leaves.png;
        polarity = "dark";
        # Use the pre-packaged Rose Pine theme
        base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
        opacity = {
          applications = 0.9;
          terminal = 0.9;
          desktop = 0.9;
          popups = 0.9;
        };
        fonts = {
          monospace = {
            package = pkgs.nerdfonts.override {
              fonts = [
                "FiraCode"
                "DroidSansMono"
              ];
            };
            name = "FiraCode Nerd Font Mono";
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
            package = pkgs.noto-fonts-emoji;
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
      };

      environment.systemPackages = with pkgs; [
        rose-pine-icon-theme
        rose-pine-cursor
      ];
    })
  ];
}
