{ lib, pkgs, config, ... }:

let
  customZshInit = pkgs.writeText "custom-zsh-init" ''
    #!/usr/bin/env zsh
    export ENV_TYPE="${config.myZshConfig.envType or "HOME"}"

    # Source Zsh plugins
    source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
    source ${pkgs.zsh-forgit}/share/zsh/zsh-forgit/forgit.plugin.zsh

    # Source fzf bindings from nix package
    source ${pkgs.fzf}/share/fzf/key-bindings.zsh

    # Custom Zsh configurations
    source $HOME/.config/zsh/aliases.zsh
    source $HOME/.config/zsh/exports.zsh
    source $HOME/.config/zsh/wsl.zsh
    # source $HOME/.config/zsh/nnn.zsh
    source $HOME/.config/zsh/bindings.zsh

      if [[ -f $HOME/.config/zsh/secrets.zsh ]]; then
  source $HOME/.config/zsh/secrets.zsh
else
  echo "The file secrets.zsh is missing. Please ensure it is created with necessary configurations."
fi


    # History settings
    HISTFILE=~/.zsh_history
    HISTSIZE=100000
    SAVEHIST=20000
    setopt hist_expire_dups_first hist_ignore_dups hist_ignore_space hist_verify inc_append_history SHARE_HISTORY

    # Load completion system
    autoload -Uz compinit
    compinit

    # Additional initialization commands
    eval "$(zoxide init zsh)"
    eval "$(starship init zsh)"
    export GPG_TTY=$(tty)
  '';
in
{
  options.myZshConfig.envType = lib.mkOption {
    type = lib.types.str;
    default = "HOME";
    description = "The type of environment, defaults to 'HOME'. Can be overridden.";
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
        cat = "bat";
        update = "sudo nixos-rebuild switch";
        sw = "sudo nixos-rebuild switch --flake ~/.config/nix#default --impure --show-trace -v";
        switchkb = "switch-keyboard-layout";
      };
    };
  };
}

