# home.nix
{ lib, config, pkgs, inputs, settings, ... }:
let isServer = settings.isServer;

in {
  config = lib.mkIf config.settings.gnome.extra.enable {
    home.packages = with pkgs; [ xdotool ];
  };

}

