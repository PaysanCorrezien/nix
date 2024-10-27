{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.settings.hyprland.extra = {
    enable = lib.mkEnableOption "Enable extra hyprland settings";
  };

  config = lib.mkIf config.settings.hyprland.extra.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = ''
        # Monitor configuration
        monitor=,preferred,auto,1

        # Set default applications
        $terminal = ${pkgs.wezterm}/bin/wezterm
        $menu = ${pkgs.wofi}/bin/wofi --show drun

        # Default environment variables
        # env = XCURSOR_SIZE,24
        env = QT_QPA_PLATFORM,wayland
        env = SDL_VIDEODRIVER,wayland
        env = GDK_BACKEND,wayland

        # Input configuration
        input {
            kb_layout = us
            follow_mouse = 1
            touchpad {
                natural_scroll = true
                tap-to-click = true
            }
            sensitivity = 0
        }

        # General configuration
        general {
            gaps_in = 5
            gaps_out = 10
            border_size = 2
            col.active_border = rgba(33ccffee)
            col.inactive_border = rgba(595959aa)
            layout = dwindle
        }

        # Window decorations
        decoration {
            rounding = 10
            blur {
                enabled = true
                size = 3
                passes = 1
                new_optimizations = true
            }
            drop_shadow = true
            shadow_range = 4
            shadow_render_power = 3
        }

        # Animations
        animations {
            enabled = true
            bezier = myBezier, 0.05, 0.9, 0.1, 1.05
            animation = windows, 1, 7, myBezier
            animation = windowsOut, 1, 7, default, popin 80%
            animation = border, 1, 10, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 6, default
        }

        # Layout configuration
        dwindle {
            pseudotile = true
            preserve_split = true
        }

        # Key bindings (translated from GNOME)
        $mainMod = ALT

        # Basic window operations
        bind = $mainMod SHIFT, Q, killactive  # Close window
        bind = $mainMod, Return, exec, $terminal  # Launch terminal
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

        # Quick settings and notifications
        bind = $mainMod, X, exec, pkill wofi || wofi --show drun  # App launcher (similar to quick settings)
        bind = $mainMod, M, exec, swaync-client -t  # Toggle notification center

        # System controls
        bind = SUPER, L, exec, systemctl suspend  # Suspend system
        bind = $mainMod, A, exec, pavucontrol  # Audio settings
        bind = $mainMod, W, exec, nm-connection-editor  # Network settings
        bind = $mainMod, B, exec, blueman-manager  # Bluetooth settings
        bind = $mainMod, S, exec, hyprctl dispatch fullscreen 1  # Toggle fullscreen

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
        windowrule = noborder, ^(wofi)$
        windowrule = center, ^(wofi)$
        windowrule = center, ^(steam)$
        windowrule = float, nm-connection-editor|blueman-manager
        windowrule = float, swayimg|vlc|Viewnior|pavucontrol
        windowrule = float, nwg-look|qt5ct|mpv
        windowrule = float, zoom

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

        # Gestures
        gestures {
            workspace_swipe = true
            workspace_swipe_fingers = 3
        }

        # General behavior settings
        misc {
            disable_autoreload = true
            disable_hyprland_logo = true
            always_follow_on_dnd = true
            layers_hog_keyboard_focus = false
            animate_manual_resizes = true
            enable_swallow = true
            swallow_regex = ^(wezterm)$
        }

        # Previous animations, decorations, etc. configs remain the same...

        # Startup applications
        exec-once = waybar
        exec-once = wl-paste --type text --watch cliphist store
        exec-once = wl-paste --type image --watch cliphist store
        exec-once = swaync
        exec-once = hyprpaper
      '';
    };
  };

}
