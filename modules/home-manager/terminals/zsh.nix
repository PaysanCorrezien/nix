# Unified Zsh configuration (works for desktop, server, and WSL)
{
  lib,
  pkgs,
  config,
  settings,
  hostName,
  ...
}:
let
  isWSL = settings.isWSL or false;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    history = {
      size = 100000;
      save = 20000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    initContent = ''
      # Environment type
      ${if isWSL then ''
        export ENV_TYPE="WSL"
        # Get Windows username using wslvar
        export WIN_USER="$(${pkgs.wslu}/bin/wslvar USERNAME 2>/dev/null || echo $USER)"
      '' else ''
        export ENV_TYPE="HOME"
      ''}

      # History settings (reinforce home-manager defaults)
      HISTSIZE=100000
      SAVEHIST=20000
      FUNCNEST=150
      setopt hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify inc_append_history SHARE_HISTORY

      # Case insensitive completion + filename
      zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}'
      setopt NO_CASE_GLOB

      # Initialize zoxide
      eval "$(zoxide init zsh)"

      # Carapace completions
      export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
      zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

      # Source fzf keybindings
      ${if isWSL then ''
        [ -f ${config.home.profileDirectory}/share/fzf/shell/key-bindings.zsh ] && source ${config.home.profileDirectory}/share/fzf/shell/key-bindings.zsh
      '' else ''
        source ${pkgs.fzf}/share/fzf/key-bindings.zsh
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      ''}

      # Source custom zsh configuration files
      source $HOME/.config/zsh/exports.zsh
      source $HOME/.config/zsh/aliases.zsh
      source $HOME/.config/zsh/bindings.zsh
      ${lib.optionalString isWSL "source $HOME/.config/zsh/windows.zsh"}

      # Source secrets file if it exists
      if [ -f $HOME/.config/zsh/secrets.zsh ]; then
        source $HOME/.config/zsh/secrets.zsh
      elif [[ -o interactive ]]; then
        echo "Warning: ~/.config/zsh/secrets.zsh is missing"
      fi

      # Prevent command from being written to history before execution
      function zshaddhistory() {
        LASTHIST=''${1//\\$'\n'/}
        return 2
      }

      # Write the last command if successful
      function precmd() {
        if [[ $? == 0 && -n ''${LASTHIST//[[:space:]\n]/} && -n $HISTFILE ]] ; then
          print -sr -- ''${=''${LASTHIST%%'\n'}}
        fi
      }

      ${lib.optionalString isWSL ''
        # Update tmux window name when directory changes
        function chpwd() {
          if [[ -n $TMUX ]]; then
            $HOME/.config/scripts/tmux-rename-window.sh 2>/dev/null || true
          fi
        }
      ''}

      ${lib.optionalString (!isWSL) ''
        # SOPS age key file
        export SOPS_AGE_KEY_FILE="/var/lib/secrets/${hostName}.txt"

        # Desktop wallpaper function
        function set-wp() {
          local wallpaper_path="$HOME/.config/nix/.wallpaper.png"
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
      ''}
    '';

    shellAliases = {
      cat = "${config.home.profileDirectory}/bin/bat --style=plain";
      man = "${config.home.profileDirectory}/bin/batman";
      diff = "${config.home.profileDirectory}/bin/batdiff";
      grep = "${config.home.profileDirectory}/bin/rg";
      sudo = "/run/wrappers/bin/sudo";
      ll = "ls -l";
      sw = "~/.config/nix/scripts/rebuild.sh";
    } // lib.optionalAttrs (!isWSL) {
      update = "sudo nixos-rebuild switch";
      compose-manager = "~/.config/nix/scripts/compose-manager.sh";
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

  # Create zsh config directory and files
  xdg.configFile = {
    "zsh/aliases.zsh".source = ./zsh/aliases.zsh;
    "zsh/bindings.zsh".source = ./zsh/bindings.zsh;
    "zsh/exports.zsh".source = ./zsh/exports.zsh;
  } // lib.optionalAttrs isWSL {
    "zsh/windows.zsh".source = ./zsh/windows.zsh;
  };
}
