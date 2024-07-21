{ config, pkgs, lib, ... }:

let cfg = config.settings.isServer;
in {
  config = lib.mkIf (!cfg) {
    environment.systemPackages = with pkgs; [
      termusic
      yt-dlp
      cmus
      mpv
      musikcube
    ];
  };
}

