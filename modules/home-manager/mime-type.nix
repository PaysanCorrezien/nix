# NOTE : command to list .desktop on nix 
# find /run/current-system/sw/share/applications ~/.nix-profile/share/applications ~/.local/share/applications -name "*.desktop" | grep wez
{ config, pkgs, ... }:

{
  # Define user-specific packages
  home.packages = with pkgs; [
  #   firefox
    xdg-utils
  ];

  # Define MIME type associations
  xdg.mimeApps = {
    enable= true;
    defaultApplications = {
      "text/html" = "firefox.desktop";
      "text/xml" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      "application/xml" = "firefox.desktop";
      "application/x-mozilla-bookmarks" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "application/x-terminal-emulator" = "org.wezfurlong.wezterm.desktop";
      "x-scheme-handler/terminal" = "org.wezfurlong.wezterm.desktop";
    };
  };

  # Set environment variables if needed
  home.sessionVariables = {
    XDG_DEFAULT_BROWSER = "firefox.desktop";
    TERMINAL = "${pkgs.wezterm}/bin/wezterm";
  };
}
