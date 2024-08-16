{ lib, config, pkgs, ... }:
let
  windowManager = config.settings.windowManager;
  cfg = config.settings;
in {
  # gsconnect need these
  # networking.firewall.allowedTCPPorts = [ 1714 1764 ];
  # networking.firewall.allowedUDPPorts = [ 1714 1764 ];
  # environment.systemPackages = with pkgs; [ gnomeExtensions.gsconnect ];

  environment.gnome.excludePackages =
    if cfg.windowManager == "gnome" && cfg.isServer == false then
      (with pkgs; [
        simple-scan
        yelp # help viewer
        gnome-calculator
        totem # video player
        evince # document viewer
        epiphany # web browser
        # cheese # webcam tool
        geary # email reader
        gnome-photos
        gnome-tour
        gnome-text-editor
      ]) ++ (with pkgs.gnome; [
        gnome-music
        # gnome-terminal
        gnome-characters
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
        gnome-maps
        # gnome-weather
        gnome-contacts
      ])
    else
      [ ];
}

