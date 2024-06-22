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
  binding =  "<Alt>Return" ;
  command =  "wezterm" ;
  name =  "Launch WezTerm" ;
};
 };
}
