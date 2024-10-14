{ config, pkgs, lib, ... }:

let cfg = config.settings.isServer;
in {
  config = lib.mkIf (!cfg) {
    environment.systemPackages = with pkgs; [
      # TODO: fix firewal port open ???
      termusic
      yt-dlp
      cmus
      mpv
      musikcube
      ncmpcpp # TODO: enable server and add conf for keyma
    ];
  };
}

