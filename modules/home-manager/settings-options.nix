# Central settings options for home-manager modules
# All module enable flags are defined here to avoid conflicts
{ lib, ... }:

{
  options.settings = lib.mkOption {
    type = lib.types.submodule {
      options = {
        # Desktop programs
        rofi = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom Rofi configuration";
          };
          default = { };
        };
        astal = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom Astal configuration";
          };
          default = { };
        };
        keepassxc = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom KeePass configuration";
          };
          default = { };
        };
        nextcloudcli = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom Nextcloud configuration";
          };
          default = { };
        };
        remmina = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom Remmina configuration";
          };
          default = { };
        };
        thunderbird = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom Thunderbird configuration";
          };
          default = { };
        };
        stylix = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom stylix configuration";
          };
          default = { };
        };
        wezterm = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "custom Wezterm configuration";
          };
          default = { };
        };

        # Window manager settings
        gnome = lib.mkOption {
          type = lib.types.submodule {
            options.extra = lib.mkOption {
              type = lib.types.submodule {
                options.enable = lib.mkEnableOption "extra GNOME configuration";
              };
              default = { };
            };
          };
          default = { };
        };
        hyprland = lib.mkOption {
          type = lib.types.submodule {
            options.extra = lib.mkOption {
              type = lib.types.submodule {
                options.enable = lib.mkEnableOption "extra hyprland settings";
              };
              default = { };
            };
          };
          default = { };
        };

        # GUI settings
        gui = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "GUI applications";
          };
          default = { };
        };
      };
    };
    default = { };
    description = "Home-manager module settings";
  };
}
