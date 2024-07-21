{ settings, pkgs, lib, ... }:

let cfg = settings.terminal.extras;
in {
  # Only apply configurations if enabled
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ jq curl ytfzf ];

    programs.zsh = {
      shellAliases = {
        yta = "ytfzf -m --sort-by=relevance -t -l --pages=3"; # search for music
        ytr =
          "ytfzf --upload-date=week --sort-by=relevance -t -l"; # search for videos uploaded this week
        yt = "ytfzf --sort-by=relevance -t -l --pages=3"; # general search
        yth =
          "$HOME/.config/scripts/parse_watch_history.sh"; # view watch history , custom fn
      };
    };
  };
}

