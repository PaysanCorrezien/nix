{ settings, pkgs, lib, ... }:

# install only if the setings is set to true
let cfg = settings.terminal.extras;
in {
  config =
    lib.mkIf cfg.enable { home.packages = with pkgs; [ jq curl yt-fzf ]; };
  programs.zsh.shellAliases = {
    yta = "ytfzf -m --sort-by=relevance -t -l --pages=3"; # search for music
    ytr =
      "ytfzf --upload-date=week --sort-by=relevance -t -l "; # search for videos uploaded this week
    yt = "ytfzf --sort-by=relevance -t -l --pages=3"; # general search
    # TODO: add more aliases for other cusxtom searches ?
  };
}
