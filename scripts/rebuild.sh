#!/usr/bin/env bash
set -euo pipefail

################################################################################
# NixOS rebuild script with git management and nh integration
#
# Usage:
#   sw              - Full rebuild with switch
#   sw --dry-run    - Build only, verify it compiles without switching
#   sw --test       - Build and activate, but don't add to boot menu
#   sw --check-all  - Build ALL hosts to verify nothing breaks
#   sw --help       - Show this help
################################################################################

# ---------------------------------------------------------------------------- #
# Parse arguments                                                              #
# ---------------------------------------------------------------------------- #
MODE="switch"
SHOW_HELP=false
CHECK_ALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run|--build|-n)
            MODE="build"
            shift
            ;;
        --test|-t)
            MODE="test"
            shift
            ;;
        --check-all|--all|-a)
            CHECK_ALL=true
            shift
            ;;
        --help|-h)
            SHOW_HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if $SHOW_HELP; then
    cat <<EOF
NixOS Rebuild Script

Usage: sw [OPTIONS]

Options:
  --dry-run, --build, -n    Build only, verify configuration compiles
  --test, -t                Build and activate without adding to boot menu
  --check-all, --all, -a    Build ALL hosts (verify changes don't break anything)
  --help, -h                Show this help message

Examples:
  sw                        Full rebuild and switch
  sw --dry-run              Test build without applying changes
  sw --test                 Test configuration (activates but no bootloader entry)
  sw --check-all            Build all hosts before committing changes
EOF
    exit 0
fi

# If --check-all, delegate to check-all-hosts.sh
if $CHECK_ALL; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    exec "$SCRIPT_DIR/check-all-hosts.sh" "$@"
fi

# ---------------------------------------------------------------------------- #
# Configuration - pulled from nix settings at runtime                          #
# ---------------------------------------------------------------------------- #
HOSTNAME=$(hostname)
# Determine flake path - check common locations
if [[ -d "$HOME/.config/nix" ]]; then
    FLAKE_PATH="$HOME/.config/nix"
elif [[ -d "/etc/nixos" ]]; then
    FLAKE_PATH="/etc/nixos"
else
    echo "Error: Cannot find flake directory"
    exit 1
fi

# Global variable for network status
NETWORK_AVAILABLE=false

# Home-manager backup extension
HM_BACKUP_EXT="HomeManagerBAK"

# ---------------------------------------------------------------------------- #
# Retrieve settings from nix configuration                                     #
# ---------------------------------------------------------------------------- #
get_setting() {
    local setting_path="$1"
    local default="${2:-}"
    local result
    result=$(nix eval --raw --accept-flake-config \
        "$FLAKE_PATH#nixosConfigurations.$HOSTNAME.config.settings.$setting_path" 2>/dev/null) || result="$default"
    echo "$result"
}

# ---------------------------------------------------------------------------- #
# Helper functions                                                             #
# ---------------------------------------------------------------------------- #
print_header() {
    echo ""
    echo "========================================"
    echo "  $1"
    echo "========================================"
}

check_network_access() {
    echo "Checking network connectivity..."
    # Use NixOS cache instead of google.com for privacy and relevance
    if curl --head --silent --fail --max-time 3 "https://cache.nixos.org" >/dev/null 2>&1; then
        echo "Network is accessible"
        NETWORK_AVAILABLE=true
        return 0
    else
        echo "No network access (cache.nixos.org unreachable)"
        NETWORK_AVAILABLE=false
        return 1
    fi
}

check_git_status_and_pull() {
    local repo_path="$1"
    echo "Checking Git status for $repo_path"

    if [[ ! -d "$repo_path/.git" ]]; then
        echo "Warning: $repo_path is not a Git repository."
        return 1
    fi

    if ! $NETWORK_AVAILABLE; then
        echo "No network access. Skipping Git operations."
        return 0
    fi

    if ! git -C "$repo_path" fetch &>/dev/null; then
        echo "Failed to fetch from remote"
        return 1
    fi

    local status
    status=$(git -C "$repo_path" status -uno)

    if echo "$status" | grep -qE "(Your branch is behind|Votre branche est en retard)"; then
        echo "There are changes available on the remote repository."

        local current_branch
        current_branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)
        local remote_branch="origin/$current_branch"
        local commit_range="$current_branch..$remote_branch"

        echo ""
        echo "Commits to be pulled:"
        git -C "$repo_path" log --pretty=format:"%h - %s (%cr) <%an>" --abbrev-commit "$commit_range" | head -10
        echo ""

        read -rp "Do you want to pull the latest changes? (y/n): " answer
        if [[ "$answer" == "y" ]]; then
            echo "Attempting to pull latest changes..."
            if ! git -C "$repo_path" pull; then
                echo "Pull failed. You have uncommitted changes."
                git -C "$repo_path" status --short
                echo ""
                while true; do
                    echo "Choose an action:"
                    echo "1) Commit changes"
                    echo "2) Stash changes"
                    echo "3) Discard changes (DESTRUCTIVE)"
                    echo "4) Skip pull"
                    read -rp "Enter your choice (1-4): " choice
                    case $choice in
                        1)
                            read -rp "Enter commit message: " commit_msg
                            git -C "$repo_path" commit -am "$commit_msg"
                            git -C "$repo_path" pull
                            break
                            ;;
                        2)
                            git -C "$repo_path" stash
                            git -C "$repo_path" pull
                            git -C "$repo_path" stash pop
                            break
                            ;;
                        3)
                            echo ""
                            echo "WARNING: This will PERMANENTLY delete all uncommitted changes!"
                            read -rp "Type 'yes' to confirm: " confirm
                            if [[ "$confirm" == "yes" ]]; then
                                git -C "$repo_path" reset --hard
                                git -C "$repo_path" clean -fd
                                git -C "$repo_path" pull
                            else
                                echo "Aborted."
                            fi
                            break
                            ;;
                        4)
                            echo "Skipping pull"
                            break
                            ;;
                        *)
                            echo "Invalid choice. Please try again."
                            ;;
                    esac
                done
            fi
            echo "Pull process complete"
        else
            echo "Skipping pull"
        fi
    else
        echo "Repository is up to date"
    fi
}

cleanup_hm_backups() {
    echo "Cleaning up home-manager backup files (*.$HM_BACKUP_EXT)..."
    local count
    count=$(find "$HOME" -type f -name "*.$HM_BACKUP_EXT" 2>/dev/null | wc -l)
    if [[ "$count" -gt 0 ]]; then
        find "$HOME" -type f -name "*.$HM_BACKUP_EXT" -delete 2>/dev/null || true
        echo "Removed $count backup file(s)"
    else
        echo "No backup files found"
    fi
}

dump_metadata() {
    local repo_path="$1"
    local config_name="$2"
    local output_dir="$HOME/.local/share/nix-metadata"
    local output_file="$output_dir/latest_build_metadata.json"

    mkdir -p "$output_dir"

    # Collect git information
    local commit_id commit_count commit_message branch
    commit_id=$(git -C "$repo_path" rev-parse HEAD 2>/dev/null || echo "unknown")
    commit_count=$(git -C "$repo_path" rev-list --count HEAD 2>/dev/null || echo "0")
    commit_message=$(git -C "$repo_path" log -1 --pretty=%B 2>/dev/null | jq -R -s . || echo '""')
    branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

    # Get nix store path
    local nix_store_path
    nix_store_path=$(readlink -f /run/current-system 2>/dev/null || echo "unknown")

    # Generate metadata JSON
    cat <<EOF >"$output_file"
{
    "build_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "hostname": "$config_name",
    "nixos_version": "$(nixos-version 2>/dev/null || echo 'unknown')",
    "mode": "$MODE",
    "git_info": {
        "commit_id": "$commit_id",
        "commit_count": $commit_count,
        "commit_message": $commit_message,
        "branch": "$branch"
    },
    "flake_path": "$repo_path",
    "flake_name": "$repo_path#$config_name",
    "nix_store_path": "$nix_store_path"
}
EOF

    echo "Metadata saved to $output_file"
}

display_settings() {
    local repo_path="$1"
    local config_name="$2"

    echo ""
    echo "Current System Settings:"
    echo "------------------------"

    local settings_data
    if settings_data=$(nix eval --json --accept-flake-config \
        "$repo_path#nixosConfigurations.$config_name.config.settings" 2>/dev/null); then
        # Try rich first, fall back to jq, then raw
        if command -v rich &>/dev/null; then
            echo "$settings_data" | rich - --json --theme monokai
        elif command -v jq &>/dev/null; then
            echo "$settings_data" | jq '.'
        else
            echo "$settings_data"
        fi
    else
        echo "(Could not retrieve settings)"
    fi
    echo "------------------------"
}

run_chezmoi_update() {
    local dotfiles_url="$1"

    if [[ -z "$dotfiles_url" ]]; then
        echo "No dotfiles URL configured, skipping chezmoi update"
        return 0
    fi

    local update_script="$HOME/.local/bin/update-dotfiles"
    if [[ -x "$update_script" ]]; then
        echo "Running chezmoi update..."
        "$update_script" "$dotfiles_url"
        echo "Chezmoi update complete"
    else
        echo "Chezmoi update script not found at $update_script, skipping"
    fi
}

# ---------------------------------------------------------------------------- #
# Main execution                                                               #
# ---------------------------------------------------------------------------- #
print_header "NixOS Rebuild - $MODE mode"

echo "Hostname: $HOSTNAME"
echo "Flake: $FLAKE_PATH#$HOSTNAME"
echo ""

# Change to flake directory
if [[ "$PWD" != "$FLAKE_PATH" ]]; then
    echo "Changing directory to $FLAKE_PATH"
    cd "$FLAKE_PATH" || {
        echo "Failed to change directory. Exiting."
        exit 1
    }
fi

# Check network
check_network_access

# Git operations (only for switch mode, skip for dry-run to be fast)
if [[ "$MODE" == "switch" ]] && $NETWORK_AVAILABLE; then
    print_header "Git Synchronization"
    check_git_status_and_pull "$FLAKE_PATH"
fi

# Cleanup home-manager backups (only for switch mode)
if [[ "$MODE" == "switch" ]]; then
    print_header "Cleanup"
    cleanup_hm_backups
fi

# Build/Switch using nh
print_header "Running nh os $MODE"

# Extra args to pass through to nix
NIX_EXTRA_ARGS=("--accept-flake-config")

# Add offline flag if no network
if ! $NETWORK_AVAILABLE; then
    echo "Running in offline mode (substitutes disabled)"
    NIX_EXTRA_ARGS+=("--option" "substitute" "false")
fi

echo "Command: nh os $MODE $FLAKE_PATH -- ${NIX_EXTRA_ARGS[*]}"
echo ""

if nh os "$MODE" "$FLAKE_PATH" -- "${NIX_EXTRA_ARGS[@]}"; then
    echo ""
    echo "nh os $MODE completed successfully"
else
    echo ""
    echo "nh os $MODE failed"
    exit 1
fi

# Post-switch operations (only if actually switching)
if [[ "$MODE" == "switch" ]]; then
    # Restart home-manager service
    print_header "Post-switch Operations"

    USERNAME=$(get_setting "username" "$USER")
    echo "Restarting home-manager-$USERNAME.service..."
    sudo systemctl restart "home-manager-$USERNAME.service" || echo "Warning: Could not restart home-manager service"

    # Chezmoi update
    if $NETWORK_AVAILABLE; then
        DOTFILES_URL=$(get_setting "paths.dotfilesUrl" "")
        run_chezmoi_update "$DOTFILES_URL"
    else
        echo "Skipping chezmoi update (no network)"
    fi

    # Dump metadata
    print_header "Build Metadata"
    dump_metadata "$FLAKE_PATH" "$HOSTNAME"

    # Display settings
    display_settings "$FLAKE_PATH" "$HOSTNAME"
fi

# Summary
echo ""
echo "========================================"
case "$MODE" in
    build)
        echo "  DRY-RUN COMPLETE - Build successful"
        echo "  Configuration compiles without errors"
        echo "  Run 'sw' to apply changes"
        ;;
    test)
        echo "  TEST COMPLETE - Configuration activated"
        echo "  Changes are temporary (not in boot menu)"
        echo "  Run 'sw' to make permanent"
        ;;
    switch)
        echo "  REBUILD COMPLETE"
        echo "  System updated and ready"
        ;;
esac
echo "========================================"
