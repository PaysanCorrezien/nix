{ lib, hostName, pkgs, config, ... }:

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
        source $HOME/.config/zsh/bindings.zsh
        # source $HOME/.config/zsh/wsl.zsh
        # source $HOME/.config/zsh/nnn.zsh
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
        FUNCNEST=150
        setopt hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify inc_append_history SHARE_HISTORY

        # make case insentive completion + filename
        zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
        setopt NO_CASE_GLOB

        # Load completion system
        autoload -Uz compinit
        compinit
        export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"


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
        # NOTE: the command stay in local shell history for editing 
        function zshaddhistory() {
          # Remove line continuations since otherwise a "\" will eventually
          # get written to history with no newline.
          LASTHIST=''${1//\\$'\n'/}
          # Return value 2: "... the history line will be saved on the internal
          # history list, but not written to the history file".
          return 2
        }
        # ~/.zshrc
        export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
        zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
        source <(carapace _carapace)

        # zsh hook called before the prompt is printed.  See zshmisc(1).
        function precmd() {
          # Write the last command if successful, using the history buffered by
          # zshaddhistory().
          if [[ $? == 0 && -n ''${LASTHIST//[[:space:]\n]/} && -n $HISTFILE ]] ; then
            print -sr -- ''${=''${LASTHIST%%'\n'}}
          fi
        }
        export SOPS_AGE_KEY_FILE="/var/lib/secrets/${hostName}.txt"
  '';
in
{
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
      historySubstringSearch.enable = true;
#TODO: reload wezterm so it also update its wallpaper ?
      initExtra = lib.readFile customZshInit + ''
        function set-wp() {
          local wallpaper_path="$HOME/.wallpaper.png"
        
          if [ -f "$1" ]; then
            local ext="''${1##*.}"
          
            if [ "$ext" = "png" ]; then
              cp "$1" "$wallpaper_path"
            else
              convert "$1" "$wallpaper_path"
            fi
          
            if [ $? -eq 0 ]; then
              echo "Wallpaper set: $1 converted and moved to $wallpaper_path"
              gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"
            else
              echo "Error: Failed to convert or copy the image."
              return 1
            fi
          else
            echo "File not found: $1"
            return 1
          fi
        }
      '';
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        sw = "~/.config/nix/scripts/rebuild.sh";
        switchkb = "switch-keyboard-layout";
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
