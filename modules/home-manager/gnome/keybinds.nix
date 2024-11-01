{
  config,
  lib,
  pkgs,
  ...
}:

let
  flameshot-gui = pkgs.writeShellScriptBin "flameshot-gui" "${pkgs.flameshot}/bin/flameshot gui";

in
{
  #TODO: maybe do an if gui enable instead
  config = lib.mkIf config.settings.gnome.extra.enable {
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        "screensaver" = [ "" ];
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13/"
        ];
      };
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
        switch-to-workspace-11 = [ "<Alt>N" ];
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
      "org/gnome/shell/keybindings" = {
        toggle-quick-settings = [ "<Alt>x" ];
        toggle-message-tray = [ "<Alt>m" ];
        toggle-application-view = [ "" ];
        show-screenshot-ui = [ ];
        open-new-window-application-1 = [ "" ];
        open-new-window-application-2 = [ "" ];
        open-new-window-application-3 = [ "" ];
        open-new-window-application-4 = [ "" ];
        open-new-window-application-5 = [ "" ];
        open-new-window-application-6 = [ "" ];
        open-new-window-application-7 = [ "" ];
        open-new-window-application-8 = [ "" ];
        open-new-window-application-9 = [ "" ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12" = {
        name = "Windows11 VM";
        command = "/home/dylan//.config/scripts/w11.sh";
        binding = "<Alt><Shift>w";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" = {
        name = "GNOME Display Settings";
        command = "gnome-control-center display";
        binding = "<Alt>s";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
        name = "Suspend System";
        command = "${pkgs.systemd}/bin/systemctl suspend";
        binding = "<Super>l";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
        name = "Gnome audio control";
        command = "gnome-control-center sound";
        binding = "<Alt>a";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
        name = "Gnome printers";
        command = "gnome-control-center printers";
        binding = "<Alt>P";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
        name = "Gnome bluetooth";
        command = "gnome-control-center bluetooth";
        binding = "<Alt>b";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
        name = "Gnome Wifi ";
        command = "gnome-control-center wifi ";
        binding = "<Alt>w";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
        name = "OCR";
        command = "zsh -c 'source ~/.zshrc && python3 /home/dylan/.config/espanso/scripts/ai-ocr.py'";
        binding = "<Alt>o";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
        name = "Grammar correct current clipboard";
        command = "zsh -c 'source ~/.zshrc && python3 /home/dylan/.config/espanso/scripts/correct.py'";
        binding = "<Alt>g";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "Todoist ";
        command = "todoist-electron";
        binding = "<Alt><Shift>t";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "Flameshot GUI";
        command = "${flameshot-gui}/bin/flameshot-gui";
        binding = "<Alt>c";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Register Task";
        command = "/home/dylan/.config/scripts/todogui.sh";
        binding = "<Alt>t";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        binding = "<Alt>Return";
        command = "/run/current-system/sw/bin/wezterm";
        name = "Launch WezTerm";
      };
      "org/gnome/shell/extensions/forge/keybindings" = {
        con-split-horizontal = [ "<Alt>z" ];
        con-split-layout-toggle = [ "<Alt>g" ];
        con-split-vertical = [ "<Alt>v" ];
        con-stacked-layout-toggle = [ "" ];
        con-tabbed-layout-toggle = [ "" ];
        focus-border-toggle = [ "" ];
        con-tabbed-showtab-decoration-toggle = [ "<Control><Alt>y" ];
        window-focus-down = [ "<Alt>j" ];
        window-focus-left = [ "<Alt>h" ];
        window-focus-right = [ "<Alt>l" ];
        window-focus-up = [ "<Alt>k" ];
        window-gap-size-decrease = [ "<Control><Alt>minus" ];
        window-gap-size-increase = [ "<Control><Alt>plus" ];
        window-move-down = [ "<Shift><Alt>j" ];
        window-move-left = [ "<Shift><Alt>h" ];
        window-move-right = [ "<Shift><Alt>l" ];
        window-move-up = [ "<Shift><Alt>k" ];
        window-resize-bottom-decrease = [ "<Shift><Control><Alt>i" ];
        window-resize-bottom-increase = [ "<Control><Alt>u" ];
        window-resize-left-decrease = [ "<Shift><Control><Alt>o" ];
        window-resize-left-increase = [ "<Control><Alt>y" ];
        window-resize-right-decrease = [ "<Shift><Control><Alt>y" ];
        window-resize-right-increase = [ "<Control><Alt>o" ];
        window-resize-top-decrease = [ "<Shift><Control><Alt>u" ];
        window-resize-top-increase = [ "<Control><Alt>i" ];
        window-snap-center = [ "<Control><Alt>c" ];
        window-snap-one-third-left = [ "<Control><Alt>d" ];
        window-snap-one-third-right = [ "<Control><Alt>g" ];
        window-snap-two-third-left = [ "<Control><Alt>e" ];
        window-snap-two-third-right = [ "<Control><Alt>t" ];
        window-swap-down = [ "<Control><Alt>j" ];
        window-swap-last-active = [ "<Alt>Return" ];
        window-swap-left = [ "<Control><Alt>h" ];
        window-swap-right = [ "<Control><Alt>l" ];
        window-swap-up = [ "<Control><Alt>k" ];
        window-toggle-float = [ "<Super>f" ]; # make windowws float
        window-toggle-always-float = [ "<Super><Shift>f" ];
        workspace-active-tile-toggle = [ "<Super>t" ]; # toggle active  mode again
      };
    };
  };
}
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
