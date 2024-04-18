{ lib, pkgs, ... }:

{
  # Enable DConf to manage GNOME settings for all users
#   programs.dconf.enable = true;

  # Set keybindings and other settings using DConf
  dconf.settings = {
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = [ "<Alt>1" ];
      switch-to-workspace-2 = [ "<Alt>2" ];
      switch-to-workspace-3 = [ "<Alt>3" ];
      switch-to-workspace-4 = [ "<Alt>4" ];
      switch-to-workspace-5 = [ "<Alt>5" ];
      switch-to-workspace-6 = [ "<Alt>6" ];
      switch-to-workspace-7 = [ "<Alt>7" ];
      switch-to-workspace-8 = [ "<Alt>8" ];
      switch-to-workspace-9 = [ "<Alt>9" ];
      switch-to-workspace-10 = [ "<Alt>0" ];
      move-to-workspace-1 = [ "<Alt><Shift>1" ];
      move-to-workspace-2 = [ "<Alt><Shift>2" ];
      move-to-workspace-3 = [ "<Alt><Shift>3" ];
      move-to-workspace-4 = [ "<Alt><Shift>4" ];
      move-to-workspace-5 = [ "<Alt><Shift>5" ];
      move-to-workspace-6 = [ "<Alt><Shift>6" ];
      move-to-workspace-7 = [ "<Alt><Shift>7" ];
      move-to-workspace-8 = [ "<Alt><Shift>8" ];
      move-to-workspace-9 = [ "<Alt><Shift>9" ];
      move-to-workspace-10 = [ "<Alt><Shift>0" ];
      close = [ "<Alt><Shift>q" ];
    };
    # FIXME: automove dont work troubleshoot
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "firefox.desktop:5"
        "org.gnome.Geary.desktop:9"
        "org.gnome.Console.desktop:1"
        "wezterm.desktop:1"
        "thunderbird.desktop:9"
        "remmina.desktop:2"
        "org.gnome.Nautilus.desktop:4"
        "org.gnome.Calendar.desktop:9"
      ];
    };
  "org/gnome/desktop/input-sources" = {
  xkb-options = [ "caps:escape" ];
};
    #FIXME
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings" = {
    custom0 = "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/";
  };
"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
  binding = [ "<Alt>Return" ];
  command = [ "wezterm" ];
  name = [ "Launch WezTerm" ];
};
#TODO: HOME AND END SOMEHOW ?

  };
}

