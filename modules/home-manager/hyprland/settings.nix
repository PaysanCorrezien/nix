{
  lib,
  config,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.settings.hyprland.extra.enable {
    home.packages = with pkgs; [
      hyprpanel
      udiskie
      # pywal
    ];
    fonts.fontconfig.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = ''
        # Monitor configuration
        monitor=,preferred,auto,1

        # Set default applications
        $terminal = ${pkgs.wezterm}/bin/wezterm
        $menu = ${pkgs.rofi}/bin/rofi -show drun

        # Default environment variables
        env = QT_QPA_PLATFORM,wayland
        env = SDL_VIDEODRIVER,wayland
        env = GDK_BACKEND,wayland

        general {
            border_size = 2       
            gaps_in = 3            
        }

        env = XCURSOR_SIZE,24               # Set cursor size
        env = XCURSOR_THEME,BreezeX-RosePine-Linux  # Make sure Hyprland knows your cursor theme
        exec-once = hyprctl setcursor BreezeX-RosePine-Linux 24

        # Input configuration
        input {
            kb_layout = us,fr
            kb_variant = altgr-intl,
            kb_options = grp:win_space_toggle
        }

        animations {
            enabled = true
            
            bezier = myBezier, 0.05, 0.9, 0.1, 1.05
            
            animation = windows, 1, 3, myBezier
            animation = windowsOut, 1, 3, default, popin 80%
            animation = border, 1, 5, default
            animation = borderangle, 1, 4, default
            animation = fade, 1, 4, default
            animation = workspaces, 1, 3, default
        }
        decoration {
        rounding = 10                # Rounded corners for all windows
        active_opacity = 1.0         # Active window is completely opaque
        inactive_opacity = 0.90      # Inactive windows are slightly transparent (90% opacity)
        }

        # Key bindings (translated from GNOME)
        $mainMod = ALT

        # Basic window operations
        bind = $mainMod SHIFT, Q, killactive  # Close window
        bind = $mainMod, Return, exec, $terminal  # Launch terminal
        bind = $mainMod, O, exec, $terminal
        bind = $mainMod, F, exec, $menu  # Launch wofi
        bind = SUPER, F, togglefloating  # Toggle floating
        bind = SUPER SHIFT, F, pin  # Toggle always on top

        # Workspace switching (ALT + number)
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10
        bind = $mainMod, N, workspace, 11

        # Move window to workspace (ALT + SHIFT + number)
        bind = $mainMod SHIFT, 1, movetoworkspace, 1
        bind = $mainMod SHIFT, 2, movetoworkspace, 2
        bind = $mainMod SHIFT, 3, movetoworkspace, 3
        bind = $mainMod SHIFT, 4, movetoworkspace, 4
        bind = $mainMod SHIFT, 5, movetoworkspace, 5
        bind = $mainMod SHIFT, 6, movetoworkspace, 6
        bind = $mainMod SHIFT, 7, movetoworkspace, 7
        bind = $mainMod SHIFT, 8, movetoworkspace, 8
        bind = $mainMod SHIFT, 9, movetoworkspace, 9
        bind = $mainMod SHIFT, 0, movetoworkspace, 10

        # Window movement (vim-style)
        bind = $mainMod, h, movefocus, l
        bind = $mainMod, l, movefocus, r
        bind = $mainMod, k, movefocus, u
        bind = $mainMod, j, movefocus, d

        bind = $mainMod SHIFT, h, movewindow, l
        bind = $mainMod SHIFT, l, movewindow, r
        bind = $mainMod SHIFT, k, movewindow, u
        bind = $mainMod SHIFT, j, movewindow, d

        # Screenshots (using grim + slurp instead of flameshot)
        bind = $mainMod, C, exec, grim -g "$(slurp)" - | wl-copy  # Screenshot to clipboard

        # Split controls (similar to your GNOME Forge setup)
        bind = $mainMod, Z, splitratio, exact 0.5  # Split horizontal
        bind = $mainMod, V, splitratio, exact 0.5  # Split vertical

        # Custom application launchers
        bind = $mainMod SHIFT, T, exec, todoist-electron

        # OCR and clipboard scripts (you'll need to adapt these)
        bind = $mainMod, O, exec, python3 $HOME/.config/espanso/scripts/ai-ocr.py
        bind = $mainMod, G, exec, python3 $HOME/.config/espanso/scripts/correct.py

        # Mouse bindings
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        # bind = ALT, E, exec, hyprpanel -t energymenu
        # alt shit w windows script
        bind = $mainMod, A, exec, hyprpanel -t audiomenu        
        bind = $mainMod, W, exec, hyprpanel -t networkmenu        
        bind = $mainMod, B, exec, hyprpanel -t bluetoothmenu     
        bind = $mainMod, M, exec, hyprpanel -t notificationsmenu
        bind = $mainMod SHIFT, M, exec, hyprpanel -t mediamenu
        bind = SUPER, L, exec, hyprpanel -t powerdropdownmenu 
        bind = $mainMod , X, exec, hyprpanel -t dashboardmenu
        bind = $mainMod SHIFT, C,exec, hyprpanel -t calendarmenu

        # Media and Function Keys
        bind = ,XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
        bind = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        bind = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        bind = ,XF86AudioPlay, exec, playerctl play-pause
        bind = ,XF86AudioPause, exec, playerctl play-pause
        bind = ,XF86AudioNext, exec, playerctl next
        bind = ,XF86AudioPrev, exec, playerctl previous
        bind = ,XF86MonBrightnessDown, exec, brightnessctl set 5%-
        bind = ,XF86MonBrightnessUp, exec, brightnessctl set +5%

        # Alt-Tab behavior
        bind = ALT, Tab, cyclenext
        bind = ALT, Tab, bringactivetotop

        # Window Rules
        # windowrule = noborder, ^(wofi)$
        # windowrule = center, ^(wofi)$
        # windowrule = center, ^(steam)$
        # windowrule = float, nm-connection-editor|blueman-manager
        # windowrule = float, swayimg|vlc|Viewnior|pavucontrol
        # windowrule = float, nwg-look|qt5ct|mpv
        # windowrule = float, zoom

        # Advanced window rules
        windowrulev2 = stayfocused, title:^()$,class:^(steam)$
        windowrulev2 = minsize 1 1, title:^()$,class:^(steam)$
        windowrulev2 = opacity 0.9 0.7, class:^(Brave)$
        windowrulev2 = opacity 0.9 0.7, class:^(thunar)$

        # Automatic workspace assignments (equivalent to GNOME auto-move-windows)
        windowrulev2 = workspace 1, class:^(org.wezterm.)$
        windowrulev2 = workspace 1, class:^(wezterm)$
        windowrulev2 = workspace 2, class:^(org.remmina.Remmina)$
        windowrulev2 = workspace 2, class:^(remmina)$
        windowrulev2 = workspace 3, class:^(todoist)$
        windowrulev2 = workspace 4, class:^(org.gnome.Nautilus)$
        windowrulev2 = workspace 4, class:^(mpv)$
        windowrulev2 = workspace 5, class:^(firefox)$
        windowrulev2 = workspace 6, class:^(discord)$
        windowrulev2 = workspace 6, class:^(element)$
        windowrulev2 = workspace 7, class:^(org.keepassxc.KeePassXC)$
        windowrulev2 = workspace 8, class:^(linphone)$
        windowrulev2 = workspace 8, class:^(microsoft-edge)$
        windowrulev2 = workspace 9, class:^(thunderbird)$
        windowrulev2 = workspace 9, class:^(org.gnome.Calendar)$
        windowrulev2 = workspace 11, class:^(obsidian)$

        # Workspace configuration
        workspace=1,name:term
        workspace=2,name:remote
        workspace=3,name:task
        workspace=4,name:file
        workspace=5,name:web
        workspace=6,name:chat
        workspace=7,name:dev
        workspace=8,name:meet
        workspace=9,name:mail
        workspace=10,name:media
        workspace=11,name:note
        workspace=12,name:extra

        # Startup applications
        # exec-once = waybar
        exec-once = hyprpanel
        exec-once = wl-paste --type text --watch cliphist store
        exec-once = wl-paste --type image --watch cliphist store
        # exec-once = swaync
        exec-once = hyprpaper
        exec-once = blueman-applet &
        exec-once = udiskie -at

      '';
    };
    dconf.settings = {
      "org.gnome.desktop.sound" = {
        event-sounds = false;
      };
      "org/gnome/desktop/applications/browser" = {
        exec = "firefox";
      };
      "org/gnome/desktop/interface" = {
        #BUG: stylix ccursor-theme dont set it properly??
        cursor-theme = lib.mkForce "BreezeX-RosePine-Linux";
      };

    };
  };

}
