{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.settings.stylix.enable {
    # stylix.enable = true;
    # stylix.image = pkgs.lib.mkDefault "${config.home.homeDirectory}/.wallpaper.png";
    # stylix.image = "/home/dylan/.wallpaper.png";
    stylix = {
      targets = {
        neovim.enable = false;
        rofi.enable = false;
      };
    };

  };
}
