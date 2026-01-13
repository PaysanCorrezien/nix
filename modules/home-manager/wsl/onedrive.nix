# OneDrive configuration
{
  lib,
  pkgs,
  config,
  ...
}: {
  # Install OneDrive client
  home.packages = with pkgs; [
    onedrive
  ];

  # Create OneDrive config directory and files
  # Note: skip_file is omitted to use built-in defaults and avoid warnings
  # If you need custom skip patterns, add: skip_file = "pattern1|pattern2|..."
  xdg.configFile."onedrive/config".text = ''
    sync_dir = "~/OneDrive"
    skip_dir = ""
    skip_dotfiles = "true"
    monitor_interval = "300"
    check_nomount = "false"
    check_nosync = "false"
    dry_run = "false"
    resync = "false"
    upload_only = "false"
    download_only = "false"
    log_dir = "~/.local/share/onedrive/log"
  '';

  xdg.configFile."onedrive/sync_list".text = ''
    Password/
    Notes/
  '';

  # OneDrive management script with fzf menu
  home.file.".config/scripts/oneD" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      # OneDrive management script with fzf menu

      # Check if fzf is available
      if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed" >&2
        exit 1
      fi

      # Menu options with indicators and descriptions
      menu_options=(
        "📊 Status|Check OneDrive service status|systemctl --user status onedrive"
        "📋 Logs|View OneDrive service logs|journalctl --user -t onedrive | less"
        "⚙️  Config|Display OneDrive configuration|onedrive --display-config"
        "🧪 Dry Run|Test sync without making changes|onedrive --dry-run"
        "🔄 Monitor|Start continuous sync daemon (Recommended)|onedrive --monitor"
        "📥 Sync|Perform a full synchronization|onedrive --sync"
        "⚠️  Resync + Sync|Full reset with sync (DANGEROUS)|onedrive --resync --sync"
        "⚠️  Resync + Monitor|Full reset with monitor (DANGEROUS)|onedrive --resync --monitor"
      )

      # Format menu for fzf (show indicator + description)
      menu_text=$(printf '%s\n' "''${menu_options[@]}" | awk -F'|' '{printf "%-25s %s\n", $1, $2}')

      # Show menu and get selection
      selected=$(echo "$menu_text" | fzf \
        --height=40% \
        --border \
        --border-label=" OneDrive Manager " \
        --prompt="⚡  " \
        --header="Select an action (ESC to cancel)" \
        --preview-window=bottom:3:wrap \
        --ansi \
        --pointer="➜" \
        --marker="✓" \
        --bind='ctrl-c:abort' \
        --bind='esc:abort')

      # Exit if nothing selected
      if [ -z "$selected" ]; then
        exit 0
      fi

      # Extract command from selected line
      # Get the indicator from the selected line
      indicator=$(echo "$selected" | awk '{print $1}')
      command=""
      for option in "''${menu_options[@]}"; do
        if echo "$option" | cut -d'|' -f1 | grep -q "$indicator"; then
          command=$(echo "$option" | cut -d'|' -f3)
          break
        fi
      done

      if [ -n "$command" ]; then
          
        # Check if it's a dangerous operation
        if echo "$command" | grep -q "resync"; then
          echo ""
          echo "⚠️  WARNING: This is a dangerous operation!"
          echo "   It will reset local DB and re-evaluate all remote state."
          echo "   Risk of overwriting local changes."
          echo ""
          read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
          if [ "$confirm" != "yes" ]; then
            echo "Operation cancelled."
            exit 0
          fi
        fi
        
        # Execute the command
        echo ""
        echo "Executing: $command"
        echo ""
        eval "$command"
        exit $?
      else
        echo "Error: Could not find command for selection" >&2
        exit 1
      fi
    '';
  };

  # Shell alias for oneD script
  programs.zsh.shellAliases = {
    oneD = "${config.home.homeDirectory}/.config/scripts/oneD";
  };

  # OneDrive systemd user service
  systemd.user.services.onedrive = {
    Unit = {
      Description = "OneDrive Sync Service";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.onedrive}/bin/onedrive --monitor";
      Restart = "on-failure";
      RestartSec = "10";
      Environment = [
        "HOME=${config.home.homeDirectory}"
      ];
      StandardOutput = "journal";
      StandardError = "journal";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}

