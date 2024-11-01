{
  lib,
  config,
  pkgs,
  ...
}:
let
  windowManager = config.settings.windowManager;
  cfg = config.settings;
in
{
  # gsconnect need these
  # networking.firewall = {
  #   allowedTCPPorts = [ 1714 1764 5357 ];  # 5357 is for WSDD
  #   allowedUDPPorts = [ 1714 1764 3702 ];  # 3702 is for WSDD
  # };
  # environment.systemPackages = with pkgs; [ gnomeExtensions.gsconnect ];
  # environment.systemPackages = with pkgs; [ gnome.gvfs ];
  # environment.systemPackages = with pkgs; [ calls ]; unfortunately, cant call as of now in kdeconnect
  # NOTE: some related issue
  # https://discourse.nixos.org/t/gsconnect-does-not-work-with-gdm/46271
  #
  # https://github.com/NixOS/nixpkgs/issues/116388#issuecomment-2257169355
  config = lib.mkIf (windowManager == "gnome") {
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    environment.systemPackages = with pkgs; [
      gjs
    ];
  };
  #   # programs.kdeconnect = {
  #   #
  #   # enable = true;
  #   # package = pkgs.gnomeExtensions.gsconnect;
  # };

  # environment.gnome.excludePackages =
  #   if cfg.windowManager == "gnome" && cfg.isServer == false then
  #     (with pkgs; [
  #       simple-scan
  #       yelp # help viewer
  #       gnome-calculator
  #       totem # video player
  #       evince # document viewer
  #       epiphany # web browser
  #       # cheese # webcam tool
  #       geary # email reader
  #       gnome-photos
  #       gnome-tour
  #       gnome-text-editor
  #     ]) ++ (with pkgs.gnome; [
  #       gnome-music
  #       # gnome-terminal
  #       gnome-characters
  #       tali # poker game
  #       iagno # go game
  #       hitori # sudoku game
  #       atomix # puzzle game
  #       gnome-maps
  #       # gnome-weather
  #       gnome-contacts
  #     ])
  #   else
  #     [ ];
}
