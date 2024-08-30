{ lib, config, pkgs, ... }:
let
  windowManager = config.settings.windowManager;
  cfg = config.settings;
in
{
  config = lib.mkIf (windowManager == "plasma") {
    programs.kdeconnect = {
      enable = true;
      # package = pkgs.gnomeExtensions.gsconnect;
    };
  };
}


