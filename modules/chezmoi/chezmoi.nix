{ config, pkgs, lib, ... }:

let cfg = config.home.programs.chezmoi;
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
      description = "Automatically apply changes after updating";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.chezmoi ];

    home.activation.chezmoiSetup =
      lib.hm.dag.entryAfter [ "installPackages" ] ''
        export PATH="${
          lib.makeBinPath (with pkgs; [ chezmoi git git-lfs ])
        }:$PATH"

        chezmoi_dir="$HOME/.local/share/chezmoi"

        error() {
          echo "ERROR: $1" >&2
          exit 1
        }

        ${builtins.trace ''

          Starting Chezmoi setup...'' ""}

        if [ ! -d "$chezmoi_dir" ]; then
          ${
            builtins.trace "Initializing chezmoi from ${cfg.repoUrl}..." ''
              $DRY_RUN_CMD chezmoi init "${cfg.repoUrl}" || error "Failed to initialize chezmoi"
            ''
          }
        else
          ${
            builtins.trace
            "Chezmoi directory exists. Checking for updates..." ''
              cd "$chezmoi_dir" || error "Failed to change to chezmoi directory"
              $DRY_RUN_CMD git fetch origin || error "Failed to fetch updates"
              if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
                ${
                  builtins.trace "Updates found. Attempting to merge..." ''
                    if ! $DRY_RUN_CMD git merge --ff-only origin/$(git rev-parse --abbrev-ref HEAD); then
                      ${
                        builtins.trace
                        "Fast-forward merge failed. Stashing local changes and trying again..." ''
                          $DRY_RUN_CMD git stash || error "Failed to stash local changes"
                          $DRY_RUN_CMD git merge --ff-only origin/$(git rev-parse --abbrev-ref HEAD) || error "Failed to merge remote changes"
                          $DRY_RUN_CMD git stash pop || ${
                            builtins.trace
                            "Warning: Failed to pop stash. You may need to manually resolve conflicts."
                            ""
                          }
                        ''
                      }
                    fi
                  ''
                }
              else
                ${builtins.trace "Local repository is up-to-date." ""}
              fi
            ''
          }
        fi

        if ${toString cfg.autoApply}; then
          ${
            builtins.trace "Applying chezmoi configuration..." ''
              $DRY_RUN_CMD chezmoi apply || error "Failed to apply chezmoi configuration"
            ''
          }
        else
          ${
            builtins.trace
            "Skipping automatic apply. Run 'chezmoi apply' manually to apply changes."
            ""
          }
        fi

        ${builtins.trace ''

          Chezmoi setup complete. Current status:'' ''
            $DRY_RUN_CMD chezmoi git status
          ''}
      '';
  };
}
