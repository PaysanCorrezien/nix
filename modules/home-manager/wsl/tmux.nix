# Tmux configuration
{
  lib,
  pkgs,
  config,
  ...
}:
{

  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 1000000;
    keyMode = "vi";
    mouse = true;
    newSession = true;
    prefix = "C-a";
    terminal = "tmux-256color";
    extraConfig = ''
            # Unbind default prefix
            unbind-key C-b
            # Keep C-a as reliable prefix, but allow C-Space as a secondary prefix for terminals
            set-option -g prefix2 C-Space
            bind C-a send-prefix
            bind C-Space send-prefix
            unbind-key s
            unbind-key v
            unbind-key t
            unbind-key n
            unbind-key w

            # Terminal overrides for colors
            set -as terminal-overrides ',xterm-256color*:RGB'
            set -g default-terminal "tmux-256color"
            # Disable focus reporting to prevent escape sequences
            set -g focus-events off

            # Default shell
            set-option -g default-shell ${pkgs.zsh}/bin/zsh
            setw -g xterm-keys on

            # Start windows and panes at 1, not 0
            set -g pane-base-index 1
            set-window-option -g pane-base-index 1
            set-option -g renumber-windows on

            # Window and pane settings
            setw -g automatic-rename off
            setw -g mode-keys vi
            set -g status on

            # Pane border and title settings
            set -g pane-border-status top
            set -g pane-border-format " #{@pane_title} "

            # Hook to rename windows based on process or path
            set-hook -ga window-pane-changed 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-window.sh"'
            set-hook -ga pane-focus-in 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-window.sh"'
            set-hook -ga after-new-window 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-window.sh"'
            set-hook -ga after-split-window 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-window.sh"'
            set-hook -ga after-select-window 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-window.sh"'
            # Initial rename when session is created
            set-hook -ga session-created 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-window.sh"'

            # Hook to update pane titles based on process or path
            set-hook -ga pane-focus-in 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-pane.sh"'
            set-hook -ga window-pane-changed 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-pane.sh"'
            set-hook -ga after-split-window 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-pane.sh"'
            set-hook -ga pane-exited 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-rename-pane.sh"'

            # Vim style pane selection
            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R

            # Split windows with current path
            bind s split-window -h -c "#{pane_current_path}"
            bind v split-window -v -c "#{pane_current_path}"

            # New window with current path
            bind t new-window -c "#{pane_current_path}"

            # Kill pane without prompt
            bind-key x kill-pane

            # Don't exit from tmux when closing a session
            set -g detach-on-destroy off

            # Pane history navigation
            # Initialize pane history
            set -g @pane_history ""
            set -g @pane_index -1

            # Hook to record pane switches globally
            set-hook -ga pane-focus-in 'run-shell "${config.home.homeDirectory}/.config/scripts/tmux-pane-history.sh"'

            # Go back through pane history
            bind b run-shell '${config.home.homeDirectory}/.config/scripts/tmux-pane-back.sh'

            # Go forward through pane history
            bind B run-shell '${config.home.homeDirectory}/.config/scripts/tmux-pane-forward.sh'

            # Shift arrow to switch windows
            bind -n S-Left  select-window -p
            bind -n S-Right select-window -n

            # Session movement
            bind k switch-client -p
            bind j switch-client -n

            # Copy mode bindings
            # Prefix + S: Enter copy mode for search/visual mode (search text)
            # Note: Shift+S might not work reliably, so we also bind lowercase s when not conflicting
            bind-key S copy-mode
            
            # Prefix + V: Enter copy mode and select entire line (visual copy)
            bind-key V copy-mode \; send-keys -X select-line
            
            # In copy mode: v for begin selection, Ctrl-v for rectangle toggle
            bind-key -T copy-mode-vi v send-keys -X begin-selection
            bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
            # y to yank (copy) selection to clipboard using helper script (WSL-safe)
            bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${config.home.homeDirectory}/.config/scripts/clipboard-copy.sh"

            # Clipboard
            set -g set-clipboard on

            # Custom session bindings
            bind N run-shell "${config.home.homeDirectory}/.config/scripts/tmux-notes-toggle.sh"
            #bind D if-shell "tmux has-session -t dotfiles" "switch-client -t dotfiles" "new-session -d -s dotfiles \; switch-client -t dotfiles \; send-keys 'cd \"/home/dylan/.local/share/chezmoi\" && lvim -c \"Telescope find_files\"' C-m"

            # Save/restore context bindings (changed from S to avoid conflict with copy-mode)
            bind-key C-s run-shell "${config.home.homeDirectory}/.config/scripts/save_tmux_context.sh"

            # Unbind p and P for PowerShell windows
            unbind-key p
            unbind-key P

            # Open non-admin pwsh in a new tmux window
            bind-key p new-window -n "pwsh" "pwsh-win"

            # Open interactive pwsh launcher (prompts for elevation/user)
            bind-key P new-window -n "pwsh-interactive" "${config.home.homeDirectory}/.config/scripts/pwsh-interactive.sh"

            # Reload config (Prefix + R)
            bind R source-file ${config.home.homeDirectory}/.config/tmux/tmux.conf
            
            # Rename session (Prefix + r)
            bind r command-prompt -I "#S" "rename-session '%%'"

            # LazyGit popup
            bind-key g display-popup -w 80% -h 80% -d "#{pane_current_path}" -E ${pkgs.lazygit}/bin/lazygit

            ## plugins bindings
            set -g @floax-bind 'w'
            set -g @floax-title 'floax'
            # Explicit binding for floax (prefix + w)
            # The plugin should create this automatically via @floax-bind, but we add it explicitly
            # to ensure it works. The plugin script should be in the tmux plugins directory.
            bind-key w run-shell "${config.home.homeDirectory}/.tmux/plugins/tmux-floax/floax.sh"

            # Sesh bindings
            bind-key "f" run-shell "sesh connect \"$(sesh list --icons | fzf-tmux -p 80%,70% --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' --bind 'tab:down,btab:up' --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' --preview-window 'right:55%' --preview 'sesh preview {}')\""
            bind-key "K" run-shell "selection=\"\$(sesh list --icons --hide-duplicates | fzf-tmux -p 80%,70% --no-border --list-border --no-sort --prompt '⚡  ' --input-border --header-border --bind 'tab:down,btab:up' --bind 'ctrl-b:abort' --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' --preview-window 'right:70%' --preview 'sesh preview {}' || true)\"; [ -n \"\$selection\" ] && sesh connect \"\$selection\""

          # root sessions (changed to Shift+R to free R for reload)
      bind-key "M-R" run-shell "selection=\"\$(sesh list --icons | fzf-tmux -p 100%,100% --no-border --query \"\$(sesh root)\" --list-border --no-sort --prompt '⚡  ' --input-border --bind 'tab:down,btab:up' --bind 'ctrl-b:abort' --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' --preview-window 'right:70%' --preview 'sesh preview {}' || true)\"; [ -n \"\$selection\" ] && sesh connect \"\$selection\""

    '';
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = vim-tmux-navigator;
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-processes 'vim nvim lvim'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-save-uptime 'on'
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '1'
          set -g @resurrect-dir "${config.home.homeDirectory}/.tmux/resurrect"
          set -g @continuum-save-file "${config.home.homeDirectory}/.tmux/resurrect/last"
        '';
      }
      {
        plugin = extrakto;
      }

      {
        plugin = catppuccin;
        extraConfig = ''
          # Configure the catppuccin plugin
          set -g @catppuccin_flavor "mocha"
          set -g @catppuccin_window_status_style "rounded"
          
          # Window status format - show window name (override catppuccin defaults)
          set -g window-status-format "#{window_name}"
          set -g window-status-current-format "#{window_name}"
          set -g @catppuccin_window_text "#{window_name}"

          # Make the status line pretty and add some modules
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          # Don't override status-right, continuum adds its save command here
          # Just append catppuccin modules to whatever is already there
          set -ag status-right "#{E:@catppuccin_status_application}"
          set -agF status-right "#{E:@catppuccin_status_cpu}"
          set -ag status-right "#{E:@catppuccin_status_session}"
          set -ag status-right "#{E:@catppuccin_status_uptime}"
          set -agF status-right "#{E:@catppuccin_status_battery}"
        '';
      }
      {
        plugin = tmux-fzf;
      }
      {
        plugin = fzf-tmux-url;
        extraConfig = ''
          set -g @fzf-url-fzf-options '-p 60%,30% --prompt="  " --border-label=" Open URL "'
          set -g @fzf-url-history-limit '2000'
        '';
      }
      {
        plugin = tmux-floax;
      }
    ];
  };

  # Add sesh and gitleaks packages
  home.packages = with pkgs; [
    gitleaks
    sesh
  ];

  # Remove legacy ad-hoc tmux user service that started tmux without our config
  home.activation.cleanLegacyTmuxService = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "${config.home.homeDirectory}/.config/systemd/user/tmux.service"
  '';

  # Create sesh config file
  home.file.".config/sesh/sesh.toml" = {
    text = ''
      blacklist = ["scratch"]
      dir_length = 2  # Uses last 2 directories: "projects/sesh" instead of just "sesh"
      sort_order = [
        "tmuxinator", # show first
        "config",
        "tmux",
        "zoxide", # show last
      ]

      [default_session]
      startup_command = "yazi"
      preview_command = "lsd --all --git --icon=auto --color=always"

      [[session]]
      name = "Downloads"
      path = "~/Downloads"
      startup_command = "yazi"

      [[session]]
      name = "repositories (c)"
      path = "~/repo"
      startup_command = "ls"

      [[session]]
      name = "home (~)"
      path = "~"
      disable_startup_command = true
    '';
  };

  # Clipboard helper that works with Windows clip.exe, Wayland, or X11
  home.file.".config/scripts/clipboard-copy.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      input="$(cat)"

      copy_with() {
        printf "%s" "$input" | "$@"
      }

      if [ -n "''${WSL_DISTRO_NAME:-}" ] && [ -x /mnt/c/Windows/System32/clip.exe ]; then
        copy_with /mnt/c/Windows/System32/clip.exe
        exit 0
      fi

      if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
        copy_with ${pkgs.wl-clipboard}/bin/wl-copy
        exit 0
      fi

      if [ -n "''${DISPLAY:-}" ]; then
        copy_with ${pkgs.xclip}/bin/xclip -selection clipboard
        exit 0
      fi

      echo "No clipboard helper available (need clip.exe on Windows or Wayland/X clipboard)" >&2
      exit 1
    '';
  };

  # Create scripts directory if needed
  home.file.".config/scripts/tmux-copymode-process-clipboard.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Process clipboard for tmux copy mode
      ${config.home.homeDirectory}/.config/scripts/clipboard-copy.sh
    '';
  };

  # Script to copy tmux buffer to system clipboard
  home.file.".config/scripts/tmux-copy-to-clipboard.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Copy tmux buffer to system clipboard
      tmux show-buffer | ${config.home.homeDirectory}/.config/scripts/clipboard-copy.sh
    '';
  };

  # Script to copy piped text (from copy-pipe) to system clipboard
  home.file.".config/scripts/tmux-copy-to-clipboard-pipe.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Copy piped text to system clipboard (used by copy-pipe)
      ${config.home.homeDirectory}/.config/scripts/clipboard-copy.sh
    '';
  };

  home.file.".config/scripts/save_tmux_context.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Save current tmux session/window
      tmux display-message -p '#S:#I' > ${config.home.homeDirectory}/.tmux_saved_context
    '';
  };

  home.file.".config/scripts/tmux-pane-history.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Record pane switches in history
      LOG_FILE="${config.home.homeDirectory}/.tmuxhistory.log"

      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [pane-history] $*" >> "$LOG_FILE"
      }

      log "=== Script started ==="
      current_pane="$(tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')"
      log "Current pane: $current_pane"

      current_history="$(tmux show -gv @pane_history 2>/dev/null)"
      if [ $? -ne 0 ]; then
        current_history=""
      fi
      log "Current history raw: '$current_history'"

      # Convert pipe-delimited string to array
      IFS='|' read -ra panes_array <<< "$current_history"
      log "Current panes array length: ''${#panes_array[@]}"

      # Don't add if it's the same as the last pane in history
      if [ ''${#panes_array[@]} -gt 0 ] && [ "''${panes_array[-1]}" = "$current_pane" ]; then
        log "Same pane as last, skipping"
        log "=== Script finished (skipped) ==="
        exit 0
      fi

      # Add current pane to array if not empty
      if [ -n "$current_pane" ]; then
        panes_array+=("$current_pane")
      fi

      # Deduplicate: remove consecutive duplicates, keep first occurrence
      new_panes=()
      prev_pane=""
      for pane in "''${panes_array[@]}"; do
        if [ -n "$pane" ] && [ "$pane" != "$prev_pane" ]; then
          new_panes+=("$pane")
          prev_pane="$pane"
        fi
      done

      # Keep only last 100 entries
      if [ ''${#new_panes[@]} -gt 100 ]; then
        new_panes=("''${new_panes[@]: -100}")
      fi

      log "New panes array length: ''${#new_panes[@]}"

      # Convert back to pipe-delimited string
      new_history=$(IFS='|'; echo "''${new_panes[*]}")
      log "New history string: '$new_history'"

      tmux set -g @pane_history "$new_history"
      log "Set @pane_history"

      # Set index to point to the last entry (current pane)
      tmux set -g @pane_index $((''${#new_panes[@]} - 1))
      log "Set @pane_index to $((''${#new_panes[@]} - 1))"
      log "=== Script finished ==="
    '';
  };

  home.file.".config/scripts/tmux-pane-back.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Navigate back through pane history
      LOG_FILE="${config.home.homeDirectory}/.tmuxhistory.log"

      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [pane-back] $*" >> "$LOG_FILE"
      }

      log "=== Script started ==="
      hist=$(tmux show -gv @pane_history 2>/dev/null)
      if [ $? -ne 0 ]; then
        hist=""
      fi
      log "History from tmux raw: '$hist'"

      idx=$(tmux show -gv @pane_index 2>/dev/null)
      if [ $? -ne 0 ]; then
        idx="-1"
      fi
      log "Current index: $idx"

      # Convert pipe-delimited string to array
      IFS='|' read -ra panes <<< "$hist"
      
      # Filter out empty entries
      panes_filtered=()
      for pane in "''${panes[@]}"; do
        if [ -n "$pane" ]; then
          panes_filtered+=("$pane")
        fi
      done
      panes=("''${panes_filtered[@]}")

      log "Filtered panes array length: ''${#panes[@]}"

      [ ''${#panes[@]} -gt 1 ] || { log "Exiting: not enough panes (''${#panes[@]})"; exit; }

      # Calculate new index (go back)
      new_idx=$((idx - 1))
      log "Calculated new_idx (idx - 1): $new_idx"

      # Wrap around if needed
      [ $new_idx -lt 0 ] && new_idx=$((''${#panes[@]} - 1))
      log "After wrap check, new_idx: $new_idx"

      target_pane=''${panes[$new_idx]}
      log "Target pane: $target_pane"

      # Parse session:window.pane format
      IFS=':.' read -ra parts <<< "$target_pane"
      session=''${parts[0]}
      window=''${parts[1]}
      pane=''${parts[2]}

      log "Parsed - session: $session, window: $window, pane: $pane"

      # Update index before switching
      tmux set -g @pane_index $new_idx
      log "Set @pane_index to $new_idx"

      # Switch to the target pane (works across sessions)
      if tmux switch-client -t "$session" 2>/dev/null; then
        tmux select-window -t "$window" 2>/dev/null
        tmux select-pane -t "$pane" 2>/dev/null
        log "Switched to pane: $target_pane"
      else
        log "ERROR: Failed to switch to $target_pane - session/window/pane may not exist"
        # Remove invalid pane from history
        new_panes=()
        for p in "''${panes[@]}"; do
          [ "$p" != "$target_pane" ] && new_panes+=("$p")
        done
        new_history=$(IFS='|'; echo "''${new_panes[*]}")
        tmux set -g @pane_history "$new_history"
        # Try to go to a valid pane instead
        if [ ''${#new_panes[@]} -gt 0 ]; then
          target_pane=''${new_panes[-1]}
          IFS=':.' read -ra parts <<< "$target_pane"
          session=''${parts[0]}
          window=''${parts[1]}
          pane=''${parts[2]}
          if tmux switch-client -t "$session" 2>/dev/null; then
            tmux select-window -t "$window" 2>/dev/null
            tmux select-pane -t "$pane" 2>/dev/null
            tmux set -g @pane_index $((''${#new_panes[@]} - 1))
            log "Switched to fallback pane: $target_pane"
          fi
        fi
        exit 0
      fi
      log "=== Script finished ==="
    '';
  };

  home.file.".config/scripts/tmux-pane-forward.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Navigate forward through pane history
      LOG_FILE="${config.home.homeDirectory}/.tmuxhistory.log"

      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [pane-forward] $*" >> "$LOG_FILE"
      }

      log "=== Script started ==="
      hist=$(tmux show -gv @pane_history 2>/dev/null)
      if [ $? -ne 0 ]; then
        hist=""
      fi
      log "History from tmux raw: '$hist'"

      idx=$(tmux show -gv @pane_index 2>/dev/null)
      if [ $? -ne 0 ]; then
        idx="-1"
      fi
      log "Current index: $idx"

      # Convert pipe-delimited string to array
      IFS='|' read -ra panes <<< "$hist"
      
      # Filter out empty entries
      panes_filtered=()
      for pane in "''${panes[@]}"; do
        if [ -n "$pane" ]; then
          panes_filtered+=("$pane")
        fi
      done
      panes=("''${panes_filtered[@]}")

      log "Filtered panes array length: ''${#panes[@]}"

      [ ''${#panes[@]} -gt 1 ] || { log "Exiting: not enough panes (''${#panes[@]})"; exit; }

      # Calculate new index (go forward)
      new_idx=$((idx + 1))
      log "Calculated new_idx (idx + 1): $new_idx"

      # Wrap around if needed
      [ $new_idx -ge ''${#panes[@]} ] && new_idx=0
      log "After wrap check, new_idx: $new_idx"

      target_pane=''${panes[$new_idx]}
      log "Target pane: $target_pane"

      # Parse session:window.pane format
      IFS=':.' read -ra parts <<< "$target_pane"
      session=''${parts[0]}
      window=''${parts[1]}
      pane=''${parts[2]}

      log "Parsed - session: $session, window: $window, pane: $pane"

      # Update index before switching
      tmux set -g @pane_index $new_idx
      log "Set @pane_index to $new_idx"

      # Switch to the target pane (works across sessions)
      if tmux switch-client -t "$session" 2>/dev/null; then
        tmux select-window -t "$window" 2>/dev/null
        tmux select-pane -t "$pane" 2>/dev/null
        log "Switched to pane: $target_pane"
      else
        log "ERROR: Failed to switch to $target_pane"
        exit 1
      fi
      log "=== Script finished ==="
    '';
  };

  home.file.".config/scripts/tmux-notes-toggle.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Toggle Notes session - if in Notes, go back; otherwise create/switch to Notes
      LOG_FILE="${config.home.homeDirectory}/.tmuxhistory.log"

      log() {
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [notes-toggle] $*" >> "$LOG_FILE"
      }

      log "=== Script started ==="

      # Get current session name
      current_session=$(tmux display-message -p '#{session_name}')
      log "Current session: $current_session"

      # If we're in Notes session, go back to previous session/pane
      if [ "$current_session" = "Notes" ]; then
        log "In Notes session, going back to previous session"
        
        # Get previous session from history
        hist=$(tmux show -gv @pane_history 2>/dev/null)
        if [ $? -ne 0 ]; then
          hist=""
        fi
        
        idx=$(tmux show -gv @pane_index 2>/dev/null)
        if [ $? -ne 0 ]; then
          idx="-1"
        fi
        
        # Convert pipe-delimited string to array
        IFS='|' read -ra panes <<< "$hist"
        
        # Filter out empty entries
        panes_filtered=()
        for pane in "''${panes[@]}"; do
          if [ -n "$pane" ]; then
            panes_filtered+=("$pane")
          fi
        done
        panes=("''${panes_filtered[@]}")
        
        # Find the last pane that's not in Notes session
        if [ ''${#panes[@]} -gt 1 ]; then
          # Go backwards through history to find non-Notes session
          for ((i=$idx-1; i>=0; i--)); do
            target_pane=''${panes[$i]}
            IFS=':.' read -ra parts <<< "$target_pane"
            session=''${parts[0]}
            if [ "$session" != "Notes" ]; then
              window=''${parts[1]}
              pane=''${parts[2]}
              tmux set -g @pane_index $i
              tmux switch-client -t "$session" 2>/dev/null
              tmux select-window -t "$window" 2>/dev/null
              tmux select-pane -t "$pane" 2>/dev/null
              log "Switched back to session: $session"
              exit 0
            fi
          done
          # If no previous non-Notes session found, try going forward
          for ((i=$idx+1; i<''${#panes[@]}; i++)); do
            target_pane=''${panes[$i]}
            IFS=':.' read -ra parts <<< "$target_pane"
            session=''${parts[0]}
            if [ "$session" != "Notes" ]; then
              window=''${parts[1]}
              pane=''${parts[2]}
              tmux set -g @pane_index $i
              tmux switch-client -t "$session" 2>/dev/null
              tmux select-window -t "$window" 2>/dev/null
              tmux select-pane -t "$pane" 2>/dev/null
              log "Switched forward to session: $session"
              exit 0
            fi
          done
        fi
        
        # Fallback: just switch to last session if available
        last_session=$(tmux list-sessions -F '#{session_name}' | grep -v "^Notes$" | tail -1)
        if [ -n "$last_session" ]; then
          tmux switch-client -t "$last_session"
          log "Switched to last non-Notes session: $last_session"
        else
          log "No other sessions available"
        fi
        exit 0
      fi

      # Not in Notes session - create/switch to Notes
      log "Not in Notes session, creating/switching to Notes"

      NOTES_DIR="$HOME/OneDrive/Notes"
      log "Notes directory: $NOTES_DIR"

      # Check if Notes session exists
      if tmux has-session -t Notes 2>/dev/null; then
        log "Notes session exists, switching to it"
        tmux switch-client -t Notes
      else
        log "Creating new Notes session"
        # Create session with nvim - use Snacks.dashboard.pick('files') as per LazyVim config
        # The command runs after shell starts, so it should work properly
        tmux new-session -d -s Notes -c "$NOTES_DIR" "nvim +\"lua Snacks.dashboard.pick('files')\""
        tmux switch-client -t Notes
        log "Created and switched to Notes session"
      fi

      log "=== Script finished (switched to Notes) ==="
    '';
  };

  # Create ensure-session script
  home.file.".tmux/scripts/ensure-session" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash

      # ensure-session <name> <dir> [command...]

      name="$1"; dir="$2"; shift 2

      if ! tmux has-session -t "$name" 2>/dev/null; then
        if [ $# -gt 0 ]; then
          tmux new-session -ds "$name" -c "$dir" "$@"
        else
          tmux new-session -ds "$name" -c "$dir"
        fi
      fi

      tmux switch-client -t "$name"
    '';
  };

  # Script to rename tmux windows based on active pane's process or path
  home.file.".config/scripts/tmux-rename-window.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rename tmux window based on active pane's process or formatted path
      # Uses the same logic as pane titles

      # Get the current window index
      current_window_index=$(tmux display-message -p '#{window_index}')
      
      # Get active pane info (the pane that currently has focus in the window)
      # Use explicit window targeting to ensure we get the correct pane for this window
      current_command=$(tmux display-message -t ":$current_window_index" -p '#{pane_current_command}')
      current_path=$(tmux display-message -t ":$current_window_index" -p '#{pane_current_path}')

      # Shell processes that should show path instead
      shell_processes=("zsh" "bash" "sh" "fish")

      # Check if current command is a shell
      is_shell=false
      for shell in "''${shell_processes[@]}"; do
        if [ "$current_command" = "$shell" ]; then
          is_shell=true
          break
        fi
      done

      if [ "$is_shell" = true ]; then
        # Format path: show last 2-3 directories
        # Replace $HOME with ~
        if [[ "$current_path" == "$HOME"* ]]; then
          formatted_path="~''${current_path#$HOME}"
        else
          formatted_path="$current_path"
        fi

        # Split path and get last 2-3 components
        IFS='/' read -ra path_parts <<< "$formatted_path"
        
        # Filter out empty parts
        parts=()
        for part in "''${path_parts[@]}"; do
          [ -n "$part" ] && parts+=("$part")
        done

        # Get last 2-3 parts, but prefer showing more context
        if [ ''${#parts[@]} -eq 0 ]; then
          window_name="~"
        elif [ ''${#parts[@]} -le 2 ]; then
          window_name=$(IFS='/'; echo "''${parts[*]}")
        else
          # Show last 3 parts for better context
          window_name=$(IFS='/'; echo "''${parts[*]: -3}")
        fi

        # Limit length to avoid too long names
        if [ ''${#window_name} -gt 30 ]; then
          window_name="...''${window_name: -27}"
        fi
      else
        # Use process name, but clean it up
        window_name="$current_command"
        
        # Remove common prefixes/suffixes
        window_name="''${window_name##*/}"
        window_name="''${window_name%.exe}"
        window_name="''${window_name%.out}"
        
        # Limit length
        if [ ''${#window_name} -gt 25 ]; then
          window_name="''${window_name:0:22}..."
        fi
      fi

      # Set the window name for the current window
      tmux rename-window -t ":$current_window_index" "$window_name"
    '';
  };

  # Script to rename tmux panes based on process or path
  home.file.".config/scripts/tmux-rename-pane.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Rename tmux pane title based on current process or formatted path
      # Updates all panes in the current window

      # Get all panes in current window
      panes=$(tmux list-panes -F '#{pane_id}')

      # Shell processes that should show path instead
      shell_processes=("zsh" "bash" "sh" "fish")

      # Update each pane's title
      for pane_id in $panes; do
        # Get pane info
        current_command=$(tmux display-message -t "$pane_id" -p '#{pane_current_command}')
        current_path=$(tmux display-message -t "$pane_id" -p '#{pane_current_path}')

        # Check if current command is a shell
        is_shell=false
        for shell in "''${shell_processes[@]}"; do
          if [ "$current_command" = "$shell" ]; then
            is_shell=true
            break
          fi
        done

        if [ "$is_shell" = true ]; then
          # Format path: show last 2-3 directories
          # Replace $HOME with ~
          if [[ "$current_path" == "$HOME"* ]]; then
            formatted_path="~''${current_path#$HOME}"
          else
            formatted_path="$current_path"
          fi

          # Split path and get last 2-3 components
          IFS='/' read -ra path_parts <<< "$formatted_path"
          
          # Filter out empty parts
          parts=()
          for part in "''${path_parts[@]}"; do
            [ -n "$part" ] && parts+=("$part")
          done

          # Get last 2-3 parts, but prefer showing more context
          if [ ''${#parts[@]} -eq 0 ]; then
            pane_title="~"
          elif [ ''${#parts[@]} -le 2 ]; then
            pane_title=$(IFS='/'; echo "''${parts[*]}")
          else
            # Show last 3 parts for better context
            pane_title=$(IFS='/'; echo "''${parts[*]: -3}")
          fi

          # Limit length to avoid too long names
          if [ ''${#pane_title} -gt 30 ]; then
            pane_title="...''${pane_title: -27}"
          fi
        else
          # Use process name, but clean it up
          pane_title="$current_command"
          
          # Remove common prefixes/suffixes
          pane_title="''${pane_title##*/}"
          pane_title="''${pane_title%.exe}"
          pane_title="''${pane_title%.out}"
          
          # Limit length
          if [ ''${#pane_title} -gt 25 ]; then
            pane_title="''${pane_title:0:22}..."
          fi
        fi

        # Set the pane title using user option (accessible via #{@pane_title})
        tmux set -t "$pane_id" @pane_title "$pane_title"
      done
    '';
  };

  # Interactive PowerShell launcher script
  home.file.".config/scripts/pwsh-interactive.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      # Interactive PowerShell launcher with optional elevation

      PWSH="/mnt/c/Program Files/PowerShell/7/pwsh.exe"
      GSUDO="/mnt/c/Program Files/gsudo/Current/gsudo.exe"

      # Check if gsudo exists
      if ! command -v "$GSUDO" >/dev/null 2>&1 && [ ! -e "$GSUDO" ]; then
        echo "gsudo not found. Install with: winget install gerardog.gsudo" >&2
        exit 2
      fi

      # Interactive prompt: current user admin or admin-interactive (other user)
      printf "PowerShell launcher options:\n"
      printf "  1) Current user (non-admin)\n"
      printf "  2) Current user (admin)\n"
      printf "  3) Other user (admin-interactive)\n"
      printf "Select option [1/2/3]: "
      read -r option

      case "$option" in
        1)
          # Non-admin current user
          exec "$PWSH"
          ;;
        2)
          # Current user as admin
          exec "$GSUDO" -d pwsh
          ;;
        3)
          # Other user with elevated rights
          read -rp "Enter Windows user to elevate as (e.g. DOMAIN\\AdminUser or .\\Administrator): " WINUSER
          if [ -z "${"WINUSER:-"}" ]; then
            echo "No user specified. Aborting." >&2
            exit 1
          fi
          exec "$GSUDO" -u "$WINUSER" -d pwsh
          ;;
        *)
          echo "Invalid option. Aborting." >&2
          exit 1
          ;;
      esac
    '';
  };
}
