{
  config,
  pkgs,
  lib,
  ...
}:

let
  # inherit (lib.gvariant) mkVariant mkTuple mkUint32 mkEmptyArray;
  inherit (lib.gvariant)
    mkVariant
    mkTuple
    mkUint32
    mkEmptyArray
    mkBoolean
    mkString
    mkArray
    mkDictionaryEntry
    ;
  myGtkTheme = pkgs.catppuccin-gtk.override {
    accents = [ "pink" ];
    size = "compact";
    tweaks = [
      "rimless"
      "black"
    ];
    variant = "macchiato";
  };
in
{
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.gnome = lib.mkOption {
          type = lib.types.submodule {
            options.extra = lib.mkOption {
              type = lib.types.submodule {
                options.enable = lib.mkEnableOption "Enable extra GNOME configuration";
              };
            };
          };
        };
      };
    };
  };

  config = lib.mkIf config.settings.gnome.extra.enable {

    # Setup the GTK theme
    gtk = {
      enable = lib.mkDefault true;
      theme = {
        name = lib.mkDefault "catppuccin-macchiato-pink-compact+rimless,black";
        package = lib.mkDefault myGtkTheme;
      };
    };

    xdg.configFile = lib.mkDefault {
      "gtk-4.0/assets".source = "${myGtkTheme}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
      "gtk-4.0/gtk.css".source = "${myGtkTheme}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
      "gtk-4.0/gtk-dark.css".source = "${myGtkTheme}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
    };

    home.packages = with pkgs; [
      gnomeExtensions.auto-move-windows
      gnomeExtensions.clipboard-indicator
      # gnomeExtensions.gsconnect
      gnomeExtensions.search-light
      gnomeExtensions.caffeine
      gnomeExtensions.space-bar
      gnomeExtensions.vitals
      gnomeExtensions.workspace-switcher-manager
      gnomeExtensions.appindicator
      gnomeExtensions.forge
      gnomeExtensions.blur-my-shell
      gnomeExtensions.clipqr
      gnomeExtensions.color-picker
      gnome-tweaks
      gucharmap
      xscreensaver
    ];

    # Configure GNOME Shell, GNOME Extensions and set the Cursor and Icons using GSettings
    dconf.settings = {

      "org/gnome/shell" = {

        disable-user-extensions = false;
        favorite-apps = [ ];
        # dconf read /org/gnome/shell/enabled-extensions
        enabled-extensions = [
          "appindicatorsupport@rgcjonas.gmail.com"
          "blur-my-shell@aunetx"
          "caffeine@patapon.info"
          "clipboard-indicator@tudmotu.com"
          "forge@jmmaranan.com"
          "gsconnect@andyholmes.github.io"
          "just-perfection-desktop@just-perfection"
          "logomenu@aryan_k"
          "search-light@icedman.github.com"
          "space-bar@luchrioh"
          "Vitals@CoreCoding.com"
          "workspace-switcher-manager@G-dH.github.com"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
          "color-picker@tuberry"
          "clipqr@drien.com"
        ];
      };

      "org/gnome/shell/extensions/user-theme" = {
        name = lib.mkDefault "catppuccin-macchiato-pink-compact+rimless,black";
      };

      "org/gnome/shell/extensions/search-light" = {
        shortcut-search = [ "<Alt>f" ];
      };
    };

  };

  # "org/gnome/shell/weather" = {
  #   locations = mkArray [
  #     (mkVariant (mkTuple [
  #       (mkUint32 2)
  #       (mkVariant (mkTuple [
  #         "Limoges"
  #         "LFBL"
  #         false
  #         (mkArray [ (mkTuple [ 0.8005243560658301 2.065305699750206e-2 ]) ])
  #         (mkArray [
  #           (mkTuple [ 0.8005243560658301 2.065305699750206e-2 ])
  #         ]) # cant use mkemptyarray here ???
  #       ]))
  #     ]))
  #   ];
  # };
  # "org/gnome/shell/world-clocks" = {
  #   locations = [
  #     (mkVariant (mkTuple [
  #       (mkUint32 2)
  #       (mkVariant (mkTuple [
  #         "Toronto"
  #         "CYTZ"
  #         true
  #         [ (mkTuple [ (0.761545324469095) (-1.3857914260834978) ]) ]
  #         [ (mkTuple [ (0.7621271125219548) (-1.3860823201099277) ]) ]
  #       ]))
  #     ]))
  #     (mkVariant (mkTuple [
  #       (mkUint32 2)
  #       (mkVariant (mkTuple [
  #         "London"
  #         "EGWU"
  #         true
  #         [ (mkTuple [ (0.8997172294030767) (-7.272211034407213e-3) ]) ]
  #         [ (mkTuple [ (0.8988445647770796) (-2.0362232784242244e-3) ]) ]
  #       ]))
  #     ]))
  #     (lib.gvariant.mkVariant (lib.gvariant.mkTuple [
  #       (lib.gvariant.mkUint32 2)
  #       (lib.gvariant.mkVariant (lib.gvariant.mkTuple [
  #         "San Francisco"
  #         "KOAK"
  #         true
  #         [
  #           (lib.gvariant.mkTuple [
  #             (0.6583284898216201)
  #             (-2.133408063190589)
  #           ])
  #         ]
  #         [
  #           (lib.gvariant.mkTuple [
  #             (0.659296885757089)
  #             (-2.136621860115334)
  #           ])
  #         ]
  #       ]))
  #     ]))
  #     (lib.gvariant.mkVariant (lib.gvariant.mkTuple [
  #       (lib.gvariant.mkUint32 2)
  #       (lib.gvariant.mkVariant (lib.gvariant.mkTuple [
  #         "Tokyo"
  #         "RJTI"
  #         true
  #         [ (lib.gvariant.mkTuple [ 0.6219189843095486 2.44084295891407 ]) ]
  #         [ (lib.gvariant.mkTuple [ 0.6228207435741766 2.4391218722853854 ]) ]
  #       ]))
  #     ]))
  #   ];
  # };

}
