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

    # ZSH Configuration
    programs.zsh = {
      shellAliases.ai = "aichat";
      # Ctrl+/ trigger for aichat prompt correction
      initContent = ''
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

    # Nushell Configuration
    programs.nushell = {
      enable = true;
      extraConfig = ''
        def "_aichat_nushell" [] {
          let _prev = (commandline)
          if ($_prev != "") {
            print '⌛'
            commandline edit -r (aichat -e $_prev)
          }
        }

        # Add keybinding for Alt+E
        $env.config.keybindings = ($env.config.keybindings | append {
          name: aichat_integration
          modifier: control
          keycode: char_u002F  # Unicode for '/' without shift
          mode: [emacs, vi_insert]
          event: [
            {
              send: executehostcommand
              cmd: "_aichat_nushell"
            }
          ]
        })
      '';
    };

    # AI Chat Configuration
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
