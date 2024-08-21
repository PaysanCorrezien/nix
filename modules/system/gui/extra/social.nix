{ config, pkgs, lib, ... }:

let cfg = config.settings.social;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # element-desktop
      discord
    ];
  };
}

