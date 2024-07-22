{ lib, pkgs, config, ... }:

let
  customZshInit = pkgs.writeText "custom-zsh-init" ''
        #!/usr/bin/env zsh
        export ENV_TYPE="${config.myZshConfig.envType or "HOME"}"

        # Source Zsh plugins
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

        # Source fzf bindings from nix package
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh

        # Custom Zsh configurations
        source $HOME/.config/zsh/aliases.zsh
        source $HOME/.config/zsh/exports.zsh
        source $HOME/.config/zsh/wsl.zsh
        # source $HOME/.config/zsh/nnn.zsh
        source $HOME/.config/zsh/bindings.zsh
        # source $HOME/.config/zsh/wezterm.sh

          if [[ -f $HOME/.config/zsh/secrets.zsh ]]; then
      source $HOME/.config/zsh/secrets.zsh
    else
      echo "The file secrets.zsh is missing. Please ensure it is created with necessary configurations."
    fi
        # avoid duplicated entries in PATH
        typeset -U PATH

        # History settings
        HISTFILE=~/.zsh_history
        HISTSIZE=100000
        SAVEHIST=20000
        setopt hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify inc_append_history SHARE_HISTORY

        # make case insentive completion + filename
        zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
        setopt NO_CASE_GLOB

        # Load completion system
        autoload -Uz compinit
        compinit

        # Additional initialization commands
        eval "$(zoxide init zsh)"
        eval "$(starship init zsh)"
        # export GPG_TTY=$(tty)

        
        # source : https://github.com/khaneliman/khanelinix/blob/main/modules/home/programs/terminal/shells/zsh/default.nix
        # Prevent the command from being written to history before it's
        # executed; save it to LASTHIST instead.  Write it to history
        # in precmd.
        #
        # called before a history line is saved.  See zshmisc(1).
        function zshaddhistory() {
          # Remove line continuations since otherwise a "\" will eventually
          # get written to history with no newline.
          LASTHIST=''${1//\\$'\n'/}
          # Return value 2: "... the history line will be saved on the internal
          # history list, but not written to the history file".
          return 2
        }

        # zsh hook called before the prompt is printed.  See zshmisc(1).
        function precmd() {
          # Write the last command if successful, using the history buffered by
          # zshaddhistory().
          if [[ $? == 0 && -n ''${LASTHIST//[[:space:]\n]/} && -n $HISTFILE ]] ; then
            print -sr -- ''${=''${LASTHIST%%'\n'}}
          fi
        }
  '';
in {
  options.myZshConfig.envType = lib.mkOption {
    type = lib.types.str;
    default = "HOME";
    description =
      "The type of environment, defaults to 'HOME'. Can be overridden.";
  };

  config = {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initExtra = lib.readFile customZshInit;
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        sw = "~/.config/nix/scripts/rebuild.sh";
        switchkb = "switch-keyboard-layout";
        # NOTE: This alias is used to find the nix package of a binary, and open the path in the file manager
        np = ''
                   function _findpkg() { 
            if [ -z "$1" ]; then 
              echo "Usage: findnixpkg <binary_name>"
              return 1
            fi
            
            binary_path=$(which "$1")
            if [ -z "$binary_path" ]; then 
              echo "Binary $1 not found"
              return 1
            fi
            
            nix_store_path=$(readlink -f "$binary_path")
            yazi $(dirname "$nix_store_path")
          }; _findpkg'';

      };
    };
  };
}

