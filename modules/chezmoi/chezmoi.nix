{ config, pkgs, ... }:

#TODO: make a template variable that get applied
#make the repo vabriable global
let
  chezmoiSetupScript = pkgs.writeShellScriptBin "chezmoi-setup" ''
    #!/bin/bash

    # URL to your chezmoi dotfiles repository
    REPO_URL="https://github.com/PaysanCorrezien/dotfiles"

    # Check if chezmoi is already set up
    if [ -d "$HOME/.config/chezmoi" ]; then
      echo "chezmoi is already set up. Applying changes..."
      chezmoi update
    else
      echo "chezmoi is not set up. Initializing from $REPO_URL..."
      chezmoi init --apply $REPO_URL
    fi
  '';
in
{
  environment.systemPackages = with pkgs; [
    chezmoi
    chezmoiSetupScript
  ];

  systemd.services.chezmoi-setup = {
    description = "Chezmoi Setup Service";
    wantedBy = [ "default.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = "${chezmoiSetupScript}/bin/chezmoi-setup";
      Type = "oneshot";
    };
  };

  systemd.services.chezmoi-setup.path = [ pkgs.chezmoi ];
}

