{
  settings,
  pkgs,
  lib,
  ...
}:
let
  cfg = settings.terminal.extras;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      aichat
      aider-chat
    ];

    programs.zsh = {
      shellAliases.ai = "aichat";
      # NOTE: this make ctrl / to trigger aichat to correct current prompt
      # https://github.com/sigoden/aichat/blob/main/scripts/shell-integration/integration.zsh
      initExtra = ''
        aichat_zsh() {
          if [[ -n "$BUFFER" ]]; then
            local _old=$BUFFER
            BUFFER+="⌛"
            zle -I && zle redisplay
            BUFFER=$(aichat -e "$_old")
            zle end-of-line
          fi
        }
        zle -N aichat_zsh
        bindkey '^_' aichat_zsh
      '';
    };

    xdg.configFile = {
      "aichat/config.yaml".text = ''
        ---
        model: openai
        clients:
          - type: openai
      '';
    };
  };
}
