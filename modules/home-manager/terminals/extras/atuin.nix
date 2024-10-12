{ pkgs, lib, settings, ... }:
let 
  cfg = settings.terminal.extras;
  readSecretFile = file:
    lib.optionalString (builtins.pathExists file) (builtins.readFile file);
  secrets = readSecretFile "/run/secrets/atuin_sync_address";
in {
  config = lib.mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "${secrets}";
        enter_accept = false;
      };
    };
    programs.zsh = {
      initExtra = ''
        eval "$(atuin init zsh)"
      '';
      shellAliases = {
        atuinfzf = ''
          atuin history list --format "{time} - {host} - {duration} - {command}" | 
          sort -r | 
          fzf --ansi --no-sort --tiebreak=index --bind=ctrl-s:toggle-sort --bind=ctrl-r:toggle-sort \
              --header 'Press CTRL-S to toggle sort' \
              --preview 'echo {}' --preview-window up:3:hidden:wrap \
              --bind 'ctrl-y:execute-silent(echo -n {4..} | cut -d" " -f4- | xclip -selection clipboard)+abort' \
              --color 'fg:188,fg+:222,bg+:#3a3a3a,hl+:104' \
              --bind 'enter:execute(echo -n {4..} | cut -d" " -f4- | xclip -selection clipboard)+abort' \
              --cycle --height=100% \
              --algo=v2
        '';
      };
    };
  };
}
