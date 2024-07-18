{ config, pkgs, lib, ... }:

let cfg = config.settings.social.enable;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ discord ];
  };
}

