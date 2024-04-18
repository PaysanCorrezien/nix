{ config, pkgs, lib, ... }:

#TODO: Custom the bar via nixconfig ? 
let
  # Customization of the GTK theme
  myGtkTheme = pkgs.catppuccin-gtk.override {
    accents = [ "pink" ];
    size = "compact";
    tweaks = [ "rimless" "black" ]; 
    variant = "macchiato";
  };
in
{
  # Setup the GTK theme
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Macchiato-Compact-Pink-Dark";
      package = myGtkTheme;
    };
  };

  # Symlink the GTK config files declaratively
  xdg.configFile."gtk-4.0/assets".source = "${myGtkTheme}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
  xdg.configFile."gtk-4.0/gtk.css".source = "${myGtkTheme}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
  xdg.configFile."gtk-4.0/gtk-dark.css".source = "${myGtkTheme}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";

  # Include GNOME Extensions, GNOME Tweaks, Cursors and Icons in Home Packages
  home.packages = with pkgs; [
    gnomeExtensions.auto-move-windows
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.gsconnect
    gnomeExtensions.search-light
    gnomeExtensions.caffeine
    gnomeExtensions.space-bar
    gnomeExtensions.vitals
    gnomeExtensions.workspace-switcher-manager
    gnomeExtensions.appindicator
    gnomeExtensions.forge
    gnomeExtensions.blur-my-shell
    gnome.gnome-tweaks
    gnome.gucharmap
 #   catppuccin-cursors
    catppuccin-cursors.macchiatoPink
    catppuccin-cursors.macchiatoLavender
    catppuccin-cursors.macchiatoMauve
   # papirus-icon-theme
   # papirus-folders
   # catppuccin-papirus-folders
  ];

  # Configure GNOME Shell, GNOME Extensions and set the Cursor and Icons using GSettings
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      favorite-apps = [
        "firefox.desktop"
      # # "code.desktop"
        "wezterm.desktop"
      #  # "spotify.desktop"
      #  # NOTE: this "virt-manager.desktop"
        "org.gnome.Nautilus.desktop"
      ];
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
      ];
    };
    "org/gnome/desktop/interface" = {
  gtk-theme = "Catppuccin-Macchiato-Compact-Pink-Dark"; # old app theme
  # icon-theme = "Catppuccin-Papirus-Dark";  # Confirm this is the correct installed name
  cursor-theme = "Catppuccin-Macchiato-Mauve-Cursors";  # Adjust to the exact name
};

# gnome general theme via user-theme extensions
"org/gnome/shell/extensions/user-theme" = {
  name = "Catppuccin-Macchiato-Compact-Pink-Dark";
};

  "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;  # Adjusted to set the number of workspaces
    };

    "org/gnome/desktop/background" = {
      # picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-l.png";
      # picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
      #FIXME: make use of relative path here
      picture-uri = "file:///home/dylan/.config/nix/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
      picture-uri-dark = "file:///home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
      picture-options = "zoom" ;              # Set wallpaper display option
    };
    # TODO: GDM theming https://github.com/catppuccin/gtk/issues/21
    # dont seems to work right now need to find what is missing
    "org/gnome/desktop/screensaver" = {
 picture-uri = "file:///home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
      primary-color = "#b7bdf8"; #catppuccin machia lavender             # Default primary color for screensaver
      secondary-color = "#f0c6c6"; # catpuccin machia  flamingo          # Default secondary color for screensaver
    };
    # extension search-light
# /org/gnome/shell/extensions/search-light/entry-font-size   /org/gnome/shell/extensions/search-light/scale-width
# /org/gnome/shell/extensions/search-light/scale-height      /org/gnome/shell/extensions/search-light/shortcut-search
    "org/gnome/shell/extensions/search-light" = {
      shortcut-search = "['<Alt>d']";  # Ensure correct syntax for the keyboard shortcut
  };
};
}
		
