{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.settings.hyprland.extra.enable {
    programs.waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [
        {
          layer = "top";
          position = "top";
          modules-center = [ "hyprland/workspaces" ];
          modules-left = [
            "custom/startmenu"
            "hyprland/window"
            "pulseaudio"
            "cpu"
            "memory"
            "idle_inhibitor"
          ];
          modules-right = [
            "custom/hyprbindings"
            "custom/notification"
            "custom/exit"
            "battery"
            "tray"
            "clock"
          ];

          "hyprland/workspaces" = {
            format = "{icon}";
            sort-by-number = true;
            persistent-workspaces = {
              "1" = [ ];
              "2" = [ ];
              "3" = [ ];
              "4" = [ ];
              "5" = [ ];
              "6" = [ ];
              "7" = [ ];
              "8" = [ ];
              "9" = [ ];
              "10" = [ ];
              "11" = [ ];
              "12" = [ ];
            };
            format-icons = {
              # "1" = " ";
              # "2" = " ";
              # "3" = "󰎚 ";
              # "4" = " ";
              # "5" = " ";
              # "6" = "󰙯 ";
              # "7" = "󰌆 ";
              # "8" = "󰏲";
              # "9" = " ";
              # "10" = "󰖂 ";
              # "11" = "󱚄";
              # "12" = "";
              "default" = " ";
              "active" = " ";
              "urgent" = " ";
            };
            on-scroll-up = "hyprctl dispatch workspace e+1";
            on-scroll-down = "hyprctl dispatch workspace e-1";
            on-click = "activate";
          };

          "clock" = {
            format = " {:%H:%M}";
            tooltip = true;
            tooltip-format = "<big>{:%A, %d.%B %Y }</big>\n<tt><small>{calendar}</small></tt>";
          };
          "hyprland/window" = {
            max-length = 22;
            separate-outputs = false;
            rewrite = {
              "" = " 🙈 No Windows? ";
            };
          };
          "memory" = {
            interval = 5;
            format = " {}%";
            tooltip = true;
          };
          "cpu" = {
            interval = 5;
            format = " {usage:2}%";
            tooltip = true;
          };
          "pulseaudio" = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };
          "custom/exit" = {
            tooltip = false;
            format = "";
            on-click = "wlogout";
          };
          "custom/startmenu" = {
            tooltip = false;
            format = "";
            on-click = "wofi --show drun";
          };
          "custom/hyprbindings" = {
            tooltip = false;
            format = "󱕴";
            on-click = "sleep 0.1 && wofi --show run";
          };
          "idle_inhibitor" = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
            tooltip = "true";
          };
          "custom/notification" = {
            tooltip = false;
            format = "{icon} {}";
            format-icons = {
              notification = "<span foreground='red'><sup></sup></span>";
              none = "";
              dnd-notification = "<span foreground='red'><sup></sup></span>";
              dnd-none = "";
              inhibited-notification = "<span foreground='red'><sup></sup></span>";
              inhibited-none = "";
              dnd-inhibited-notification = "<span foreground='red'><sup></sup></span>";
              dnd-inhibited-none = "";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t";
            escape = true;
          };
          "battery" = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = "󰂄 {capacity}%";
            format-plugged = "󱘖 {capacity}%";
            format-icons = [
              "󰁺"
              "󰁻"
              "󰁼"
              "󰁽"
              "󰁾"
              "󰁿"
              "󰂀"
              "󰂁"
              "󰂂"
              "󰁹"
            ];
            tooltip = false;
          };
        }
      ];

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font";
          font-size: 16px;
          border-radius: 0px;
          transition-property: background-color;
          transition-duration: 0.5s;
        }
        window#waybar {
          background-color: rgba(0, 0, 0, 0.2);
          border-bottom: 2px solid #1e1e2e;
        }
        #workspaces {
          background: #1e1e2e;
          margin: 4px 4px;
          padding: 5px 5px;
          border-radius: 16px;
        }
        #workspaces button {
          padding: 0px 8px;  /* Increased padding for better icon visibility */
          margin: 0px 3px;
          border-radius: 16px;
          color: #cdd6f4;
          background: linear-gradient(45deg, #f38ba8, #89b4fa);
          opacity: 0.5;
          transition: all 0.3s ease;
          font-size: 18px;  /* Slightly larger font size for icons */
        }
        #workspaces button.active {
          padding: 0px 8px;
          margin: 0px 3px;
          border-radius: 16px;
          background: linear-gradient(45deg, #f38ba8, #89b4fa);
          opacity: 1.0;
          min-width: 44px;
          font-size: 18px;
        }
        #workspaces button:hover {
          background: linear-gradient(45deg, #f38ba8, #89b4fa);
          opacity: 0.8;
        }
        tooltip {
          background: #1e1e2e;
          border: 1px solid #f38ba8;
          border-radius: 12px;
        }
        tooltip label {
          color: #cdd6f4;
        }
        #window, 
        #pulseaudio, 
        #cpu, 
        #memory, 
        #idle_inhibitor {
          margin: 4px 0px;
          margin-left: 7px;
          padding: 0px 18px;
          background: #45475a;
          color: #cdd6f4;
          border-radius: 24px 10px 24px 10px;
        }
        #custom-startmenu {
          color: #a6e3a1;
          background: #313244;
          font-size: 20px;
          margin: 0px;
          padding: 0px 30px 0px 15px;
          border-radius: 0px 0px 40px 0px;
        }
        #custom-hyprbindings,
        #network,
        #battery,
        #custom-notification,
        #tray,
        #custom-exit {
          background: #f2cdcd;
          color: #1e1e2e;
          margin: 4px 0px;
          margin-right: 7px;
          border-radius: 10px 24px 10px 24px;
          padding: 0px 18px;
        }
        #clock {
          color: #1e1e2e;
          background: linear-gradient(90deg, #cba6f7, #94e2d5);
          margin: 0px;
          padding: 0px 15px 0px 30px;
          border-radius: 0px 0px 0px 40px;
        }
      '';
    };
  };
}
