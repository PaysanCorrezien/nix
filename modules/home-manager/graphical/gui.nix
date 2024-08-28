# home.nix
{ lib, config, pkgs, inputs, settings, ... }:

 {
  config = lib.mkIf config.settings.gnome.extra.enable {
    home.packages = with pkgs; [ xdotool ];
  };

}

