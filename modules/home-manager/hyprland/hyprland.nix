#NOTE : starting point
#TEST: need to be done
{ pkgs, ... }: 
{
  # Enable Hyprland in Home Manager
  wayland.windowManager.hyprland = {
    enable = true;

    # Additional settings can be added here
    settings = {
      "$mod" = "SUPER";
      bind = [
        "$mod, F, exec, firefox"
        ", Print, exec, grimblast copy area"
      ] ++ (
        builtins.concatLists (builtins.genList (
          x: let
            ws = builtins.toString (x + 1);
          in [
            "$mod, ${ws}, workspace, ${ws}"
            "$mod SHIFT, ${ws}, movetoworkspace, ${ws}"
          ]
        ) 10)
      );
    };
    monitor {
        name = "eDP-1";
        width = 1920;
        height = 1080;
        refreshRate = 60;
      }

    # Fixing problems with themes
    systemd.variables = ["--all"];
  };

  # Configuring themes
  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;
    theme = {
      package = pkgs.flat-remix-gtk;
      name = "Flat-Remix-GTK-Grey-Darkest";
    };

    iconTheme = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };
}

