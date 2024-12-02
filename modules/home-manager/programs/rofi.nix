{
  config,
  lib,
  pkgs,
  ...
}:
{
  options = {
    settings = lib.mkOption {
      type = lib.types.submodule {
        options.rofi = lib.mkOption {
          type = lib.types.submodule {
            options.enable = lib.mkEnableOption "Enable custom Rofi configuration";
          };
        };
      };
    };
  };
  config = lib.mkIf config.settings.rofi.enable {
    home.packages = with pkgs; [
      xdotool
      rofi-bluetooth
      rofi-systemd
      # rofi-rbw
      rofimoji
      ani-cli
      # networkmanager_dmenu
    ];
    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      terminal = "${pkgs.wezterm}/bin/wezterm";
      font = "Iosevka Nerd Font Medium 11";
      plugins = with pkgs; [
        rofi-calc
        rofi-bluetooth
        rofi-rbw # Bitwarden integration
        rofi-power-menu
        rofi-systemd
      ];
      extraConfig = {
        modi = "drun,run,window,ssh,filebrowser";
        show-icons = true;
        drun-display-format = "{name}";
        disable-history = false;
        hide-scrollbar = false;
        display-drun = "󰀻  Apps ";
        display-run = "󱓞  Run ";
        display-window = "🪟  Window";
        display-ssh = "󰣀 SSH";
        display-keys = "  Keys";
        display-filebrowser = "📁 Files";
        display-calc = "󰪚  Calc";
        display-bluetooth = "  BT";
        display-systemd = " Services";
        sidebar-mode = true;
      };
      theme =
        let
          inherit (config.lib.formats.rasi) mkLiteral;
        in
        {
          "*" = {
            font = mkLiteral "\"Iosevka Nerd Font Medium 11\"";
            bg0 = mkLiteral "#1a1b26";
            bg1 = mkLiteral "#1f2335";
            bg2 = mkLiteral "#24283b";
            bg3 = mkLiteral "#414868";
            fg0 = mkLiteral "#c0caf5";
            fg1 = mkLiteral "#a9b1d6";
            fg2 = mkLiteral "#737aa2";
            red = mkLiteral "#f7768e";
            green = mkLiteral "#9ece6a";
            yellow = mkLiteral "#e0af68";
            blue = mkLiteral "#7aa2f7";
            magenta = mkLiteral "#9a7ecc";
            cyan = mkLiteral "#4abaaf";
            accent = mkLiteral "@red";
            urgent = mkLiteral "@yellow";
            "background-color" = mkLiteral "transparent";
            "text-color" = mkLiteral "@fg0";
            margin = 0;
            padding = 0;
            spacing = 0;
          };

          "element-icon, element-text, scrollbar" = {
            cursor = mkLiteral "pointer";
          };

          window = {
            location = mkLiteral "center";
            width = 800; # Increased from 600
            height = mkLiteral "70%"; # Increased from 60%
            "background-color" = mkLiteral "@bg1";
            border = 1;
            "border-color" = mkLiteral "@bg3";
            "border-radius" = 6;
          };

          inputbar = {
            spacing = 8;
            padding = mkLiteral "4px 8px";
            children = map mkLiteral [
              "icon-search"
              "entry"
            ];
            "background-color" = mkLiteral "@bg0";
          };

          "icon-search, entry, element-icon, element-text" = {
            "vertical-align" = mkLiteral "0.5";
          };

          "icon-search" = {
            expand = false;
            filename = mkLiteral "\"search-symbolic\"";
            size = 14;
          };

          textbox = {
            padding = mkLiteral "4px 8px";
            "background-color" = mkLiteral "@bg2";
          };

          listview = {
            padding = mkLiteral "4px 0px";
            lines = 12;
            columns = 1;
            scrollbar = true;
            "fixed-height" = false;
            dynamic = true;
          };

          element = {
            padding = mkLiteral "4px 8px";
            spacing = 8;
          };

          "element normal urgent" = {
            "text-color" = mkLiteral "@urgent";
          };

          "element normal active" = {
            "text-color" = mkLiteral "@accent";
          };

          "element alternate active" = {
            "text-color" = mkLiteral "@accent";
          };

          "element selected" = {
            "text-color" = mkLiteral "@bg1";
            "background-color" = mkLiteral "@accent";
          };

          "element selected urgent" = {
            "background-color" = mkLiteral "@urgent";
          };

          "element-icon" = {
            size = mkLiteral "0.8em";
          };

          "element-text" = {
            "text-color" = mkLiteral "inherit";
          };

          scrollbar = {
            "handle-width" = 4;
            "handle-color" = mkLiteral "@fg2";
            padding = mkLiteral "0 4px";
          };
        };
    };

    home.file.".config/rofi/input.rasi".text = ''
      configuration {
        font: "Iosevka Nerd Font Medium 11";
      }
      * {
        bg0: #1a1b26;
        bg1: #1f2335;
        bg2: #24283b;
        bg3: #414868;
        fg0: #c0caf5;
        fg2: #737aa2;
        red: #f7768e;
        accent: @red;
        text-color: @fg0;
        margin: 0px;
        padding: 0px;
        spacing: 0px;
      }
      window {
        width: 30%;
        height: 30%;
        location: center;
        anchor: center;
        background-color: @bg1;
        border: 1;
        border-color: @bg3;
        border-radius: 6;
      }
      mainbox {
        children: [ inputbar ];
      }
      inputbar {
        padding: 8px;
        spacing: 4px;
        background-color: @bg0;
      }
      prompt {
        text-color: @accent;
      }
      entry {
        text-color: @fg0;
        placeholder-color: @fg2;
      }
    '';

  };

}
