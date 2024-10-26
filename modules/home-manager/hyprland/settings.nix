{ config, lib, pkgs, ... }:

let
  username = "dylan"; # Adjust this if necessary
in
{
  options.settings.hyprland.extra = {
    enable = lib.mkEnableOption "Enable extra hyprland settings";
  };

  config = lib.mkIf config.settings.hyprland.extra.enable {
    home.packages = with pkgs; [
 kitty
 wofi
 hyprpaper
  ];
      # programs.hyprland.portalPackage = pkgs.xdg-desktop-portal-hyprland;
      # programs.hyprland.systemd.setPath.enable = true;
      # programs.hyprland.xwayland.enable = true;
      #
      # # Additional programs/services related to Hyprland
      # programs.iio-hyprland.enable = config.settings.windowManager == "hyprland";
      # services.hypridle.enable = config.settings.windowManager == "hyprland";
      # programs.hyprlock.enable = config.settings.windowManager == "hyprland";
      # # programs.uwsm.enable = config.settings.windowManager == "hyprland";

  };
}
