# home.nix
{ lib, config, pkgs, inputs, settings, ... }:
let isServer = settings.isServer;

in {
  # imports = [
  #
  # ];

  home.packages = with pkgs; [ xdotool ];

}

