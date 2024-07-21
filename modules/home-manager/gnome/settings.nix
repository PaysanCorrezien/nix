{ lib, pkgs, ... }:

{
  # Enable DConf to manage GNOME settings for all users
  #   programs.dconf.enable = true;

  # Set keybindings and other settings using DConf
  dconf.settings = {
    "org.gnome.desktop.sound" = {
      event-sounds = false;
    }; # disable annoying sound alter
    # FIXME: automove dont work troubleshoot
    "org/gnome/shell/extensions/auto-move-windows" = {
      #NOTE: finding .desktop on nixos !
      # ❯ find /run/current-system/sw/share/applications ~/.nix-profile/share/applications ~/.local/share/applications -name "*.desktop" | grep discord
      application-list = [
        "org.gnome.Console.desktop:1"
        "wezterm.desktop:1"
        "remmina.desktop:2"
        "org.remmina.Remmina.desktop:2"
        "org.gnome.Nautilus.desktop:4"
        "mpv.desktop:4"
        "umpv.desktop:4"
        "firefox.desktop:5"
        "discord.desktop:6"
        "org.keepassxc.KeePassXC.desktop:7"
        "linphone.desktop:8"
        "org.gnome.Geary.desktop:9"
        "thunderbird.desktop:9"
        "org.gnome.Calendar.desktop:9"
        "obsidian.desktop:11"
      ];
    };
    "org/gnome/desktop/input-sources" = { xkb-options = [ "caps:escape" ]; };
    "org/gnome/desktop/applications/browser" = { exec = "firefox"; };
    #TODO: HOME AND END SOMEHOW ?

    "org/gnome/desktop/background" = {
      #FIXME: make use of relative path here
      picture-uri =
        "file:///home/dylan/.config/nix/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
      picture-uri-dark =
        "file:///home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
      picture-options = "zoom"; # Set wallpaper display option
    };
    # dont seems to work right now need to find what is missing
    "org/gnome/desktop/screensaver" = {
      picture-uri =
        "file:///home/dylan/.config/nixos/modules/home-manager/gnome/backgrounds/wallpaper_leaves.png";
      primary-color =
        "#b7bdf8"; # catppuccin machia lavender             # Default primary color for screensaver
      secondary-color =
        "#f0c6c6"; # catpuccin machia  flamingo          # Default secondary color for screensaver
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 11; # Adjusted to set the number of workspaces
      workspace-names = [
        " "
        " "
        "󰎚 "
        " "
        " "
        "󰙯 "
        "󰌆 "
        "󰏲"
        " "
        "󰖂 "
        "󱚄"
      ]; # icon for each workpace from one to 11 in order
      # theme = "Catppuccin-Macchiato-Compact-Pink-Dark";
    };
  };
}
# find settings
# gsettings list-recursively | grep media-keys

