{ config, lib, pkgs, ... }:

{
  # xdg.configFile."dconf/user".text = lib.mkAfter ''
  #   [org/gnome/settings-daemon/plugins/media-keys]
  #   custom-keybindings = ['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']
  #
  #   [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
  #   name = 'Launch WezTerm'
  #   command = 'wezterm'
  #   binding = '<Alt>Return'
  # '';
  # Enable the dconf module

  # Define the custom keybinding settings
  #NOTE: credit https://gitlab.com/engmark/root/-/merge_requests/446/diffs
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Register Task";
      command = "/home/dylan/.config/scripts/todogui.sh";
      binding = "<Alt>t";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Alt>Return";
      command = "wezterm";
      name = "Launch WezTerm";
    };

    # obtaining the list like this
    # dconf dump '/org/gnome/shell/extensions/forge/keybindings/' > dconf-forge-keybindings.ini
    # Forge keybindings
    "org/gnome/shell/extensions/forge/keybindings" = {
      con-split-horizontal = ["<Alt>z"];
      con-split-layout-toggle = ["<Alt>g"];
      con-split-vertical = ["<Alt>v"];
      con-stacked-layout-toggle = ["<Shift><Alt>s"];
      con-tabbed-layout-toggle = ["<Shift><Alt>t"];
      con-tabbed-showtab-decoration-toggle = ["<Control><Alt>y"];
      # focus-border-toggle = ["<Alt>x"]; always on is better
      prefs-tiling-toggle = ["<Alt>w"];
      window-focus-down = ["<Alt>j"];
      window-focus-left = ["<Alt>h"];
      window-focus-right = ["<Alt>l"];
      window-focus-up = ["<Alt>k"];
      window-gap-size-decrease = ["<Control><Alt>minus"];
      window-gap-size-increase = ["<Control><Alt>plus"];
      window-move-down = ["<Shift><Alt>j"];
      window-move-left = ["<Shift><Alt>h"];
      window-move-right = ["<Shift><Alt>l"];
      window-move-up = ["<Shift><Alt>k"];
      window-resize-bottom-decrease = ["<Shift><Control><Alt>i"];
      window-resize-bottom-increase = ["<Control><Alt>u"];
      window-resize-left-decrease = ["<Shift><Control><Alt>o"];
      window-resize-left-increase = ["<Control><Alt>y"];
      window-resize-right-decrease = ["<Shift><Control><Alt>y"];
      window-resize-right-increase = ["<Control><Alt>o"];
      window-resize-top-decrease = ["<Shift><Control><Alt>u"];
      window-resize-top-increase = ["<Control><Alt>i"];
      window-snap-center = ["<Control><Alt>c"];
      window-snap-one-third-left = ["<Control><Alt>d"];
      window-snap-one-third-right = ["<Control><Alt>g"];
      window-snap-two-third-left = ["<Control><Alt>e"];
      window-snap-two-third-right = ["<Control><Alt>t"];
      window-swap-down = ["<Control><Alt>j"];
      window-swap-last-active = ["<Alt>Return"];
      window-swap-left = ["<Control><Alt>h"];
      window-swap-right = ["<Control><Alt>l"];
      window-swap-up = ["<Control><Alt>k"];
      window-toggle-always-float = ["<Shift><Alt>c"];
      window-toggle-float = ["<Alt>c"];
      workspace-active-tile-toggle = ["<Shift><Alt>w"];
    };
  };
}
