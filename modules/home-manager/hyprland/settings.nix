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
  };
}
