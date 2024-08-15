{ config, pkgs, lib, ... }:

let
  cfg = config.home.programs.chezmoi;
  chezmoiSetupScript = pkgs.writeShellScript "chezmoi-setup" ''
    set -euo pipefail

    notify() {
      ${pkgs.libnotify}/bin/notify-send -u "$1" -t 5000 "Chezmoi Setup" "$2"
    }

    echo "Starting Chezmoi setup..."
    HOME_DIR=$(eval echo ~$USER)
    echo "Home directory: $HOME_DIR"
    echo "Chezmoi repo URL: ${cfg.repoUrl}"
    echo "Auto apply: ${toString cfg.autoApply}"

    chezmoi_dir="$HOME_DIR/.local/share/chezmoi"
    echo "Chezmoi directory: $chezmoi_dir"

    if [ ! -d "$chezmoi_dir" ]; then
      echo "Initializing chezmoi from ${cfg.repoUrl}"
      if ${pkgs.chezmoi}/bin/chezmoi init "${cfg.repoUrl}"; then
        notify "normal" "Chezmoi initialized successfully"
      else
        error_msg="Failed to initialize Chezmoi"
        echo "$error_msg"
        notify "critical" "$error_msg"
        exit 1
      fi
    fi

    echo "Updating chezmoi repository and applying changes..."
    if ${pkgs.chezmoi}/bin/chezmoi update; then
      echo "Successfully updated and applied chezmoi configuration"
      notify "normal" "Chezmoi configuration updated and applied successfully"
    else
      error_msg="Errors occurred while updating or applying chezmoi configuration"
      echo "WARNING: $error_msg"
      echo "Please review the output above and resolve any conflicts manually"
      notify "critical" "WARNING: $error_msg Manual review required."
    fi

    echo "Chezmoi setup complete"
  '';
in {
  options.home.programs.chezmoi = {
    enable = lib.mkEnableOption "Chezmoi dotfiles manager";
    repoUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/PaysanCorrezien/dotfiles";
      description = "URL of your chezmoi dotfiles repository";
    };
    autoApply = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description =
        "Automatically apply changes after initializing or updating";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.chezmoi pkgs.libnotify ];

    home.activation.chezmoiSetup =
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        ${builtins.trace "Starting Chezmoi setup..." ''
          ${builtins.trace "Chezmoi repo URL: ${cfg.repoUrl}" ''
            ${builtins.trace "Auto apply: ${toString cfg.autoApply}" ''
              $DRY_RUN_CMD ${chezmoiSetupScript}
            ''}
          ''}
        ''}
      '';
  };
}
