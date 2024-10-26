{ lib, config, ... }:
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
        # image = "/home/${config.settings.username}/.wallpaper.png";
        image = ../../../../modules/home-manager/gnome/backgrounds/wallpaper_leaves.png;
      };
    })
  ];
}
