{ lib, pkgs, config, ... }:

let
  # Custom Zsh configuration script
  # Utilize the `config.myZshConfig.envType` to set ENV_TYPE
  # NOTE: This allow setting a global variable for the shell to tell it which type of env im on via nixos config
  # {
  #  myZshConfig.envType = "WORK";
  # }


  customZshInit = pkgs.writeText "custom-zsh-init" ''
    #!/usr/bin/env zsh
    # Set default ENV_TYPE based on configuration or default to "HOME"
    export ENV_TYPE="${config.myZshConfig.envType or "HOME"}"

    # Source the zsh-fzf-tab plugin
    source ${pkgs.zsh-fzf-tab}/share/zsh/site-functions/zsh-fzf-tab.plugin.zsh

    # Source the zsh-forgit plugin
    source ${pkgs.zsh-forgit}/share/zsh/site-functions/zsh-forgit.plugin.zsh

    # Additional Zsh customizations can go here
  '';
in
{
  # Option for setting the ENV_TYPE environment variable
  options.myZshConfig.envType = lib.mkOption {
    type = lib.types.str;
    default = "HOME";
    description = "The type of environment, defaults to 'HOME'. Can be overridden.";
  };

  # Configure Zsh
  config = {
    programs.zsh = {
      enable = true;
      initExtra = lib.readFile customZshInit;
    };
  };
}

