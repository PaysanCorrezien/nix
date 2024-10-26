{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.stylix = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "Enable custom stylix configuration";
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.stylix.enable {
    # stylix.enable = true;
    # stylix.image = pkgs.lib.mkDefault "${config.home.homeDirectory}/.wallpaper.png";
    # stylix.image = "/home/dylan/.wallpaper.png";
    stylix = {
      targets = {
        neovim.enable = false;
      };
    };

  };
}
