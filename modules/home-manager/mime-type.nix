{ config, pkgs, ... }:

{

# NOTE : command to list .desktop on nix 
# find /run/current-system/sw/share/applications ~/.nix-profile/share/applications ~/.local/share/applications -name "*.desktop" | grep wez

  xdg = {
    mimeApps.defaultApplications = {
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "application/x-terminal-emulator" = "org.wezfurlong.wezterm.desktop";
    };
  };
}

