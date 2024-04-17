{ config, lib, pkgs, ... }:

{
  xdg.configFile."dconf/user".text = lib.mkAfter ''
    [org/gnome/settings-daemon/plugins/media-keys]
    custom-keybindings = ['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

    [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
    name = 'Launch WezTerm'
    command = 'wezterm'
    binding = '<Alt>Return'
  '';
}

