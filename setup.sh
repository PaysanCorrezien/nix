#!/usr/bin/env bash
set -e
set -x

################################################################################
# NixOS unattended installer
# - Selects a host flake from a Git repo
# - Runs disko + nixos-install
# - Pre‑installs an Age/SOPS key so secrets can be decrypted during the build
################################################################################

# Hard‑coded username for the first boot (override in your flake if needed)
USER_NAME="dylan"

# ---------------------------------------------------------------------------- #
# Workspace
# ---------------------------------------------------------------------------- #
TEMP_REPO_DIR="/tmp/nixos-config"
[ -d "$TEMP_REPO_DIR" ] && {
	echo "Removing existing $TEMP_REPO_DIR"
	rm -rf "$TEMP_REPO_DIR"
}

# ---------------------------------------------------------------------------- #
# Dependencies
# ---------------------------------------------------------------------------- #
echo "Installing git and fzf …"
nix-env -iA nixos.git nixos.fzf -q >/dev/null

# ---------------------------------------------------------------------------- #
# Clone flake
# ---------------------------------------------------------------------------- #
REPO_URL="https://github.com/paysancorrezien/nix.git"
echo "Cloning configuration repository …"
git clone "$REPO_URL" "$TEMP_REPO_DIR"

# ---------------------------------------------------------------------------- #
# Pick a host
# ---------------------------------------------------------------------------- #
mapfile -t CONFIGS < <(ls "$TEMP_REPO_DIR"/hosts/*.nix | xargs -n1 basename | sed 's/\.nix$//')
((${#CONFIGS[@]} == 0)) && {
	echo "No host files found under hosts/*.nix"
	exit 1
}

CONFIG=$(printf '%s\n' "${CONFIGS[@]}" | fzf --height=10 --layout=reverse --prompt="Select host > ")
[ -z "$CONFIG" ] && {
	echo "Nothing selected; aborting."
	exit 1
}

echo "Host selected: $CONFIG"

# ---------------------------------------------------------------------------- #
# Install Age/SOPS key BEFORE nixos-install so evaluation can decrypt secrets
# ---------------------------------------------------------------------------- #
AGE_KEY_TEMP=$(find /tmp -maxdepth 1 -name "*.age" -o -name "*.txt" | head -n1)
if [[ -n "$AGE_KEY_TEMP" ]]; then
	AGE_KEY_DEST="/mnt/var/lib/secrets/${CONFIG}.txt"
	echo "Copying Age key → $AGE_KEY_DEST"
	sudo mkdir -p "$(dirname "$AGE_KEY_DEST")"
	sudo install -m 600 "$AGE_KEY_TEMP" "$AGE_KEY_DEST"
else
	echo "! No Age key found in /tmp. The build may fail if it needs to decrypt secrets or fallback to default values."
fi

# ---------------------------------------------------------------------------- #
# Partition / format / mount via disko
# ---------------------------------------------------------------------------- #
echo "Running disko for $CONFIG …"
sudo nix --experimental-features "nix-command flakes" run \
	github:nix-community/disko/latest -- \
	--mode disko --flake "$TEMP_REPO_DIR#$CONFIG" --no-write-lock-file

# ---------------------------------------------------------------------------- #
# nixos-install (env var exposes key to the build)
# ---------------------------------------------------------------------------- #
echo "Starting nixos-install …"
sudo SOPS_AGE_KEY_FILE="/var/lib/secrets/${CONFIG}.txt" \
	nixos-install --flake "$TEMP_REPO_DIR#$CONFIG" --show-trace --impure

# ---------------------------------------------------------------------------- #
# Move flake into the target system for convenience
# ---------------------------------------------------------------------------- #
FINAL_REPO_DIR="/mnt/home/$USER_NAME/.config/nix"
echo "Moving flake into $FINAL_REPO_DIR …"
sudo mkdir -p "$(dirname "$FINAL_REPO_DIR")"
sudo mv "$TEMP_REPO_DIR" "$FINAL_REPO_DIR"

# ---------------------------------------------------------------------------- #
# Cleanup
# ---------------------------------------------------------------------------- #
[ -d "$TEMP_REPO_DIR" ] && rm -rf "$TEMP_REPO_DIR"

printf '\nInstallation finished. Reboot into your new system.\n'
printf '• Age key copied to /var/lib/secrets/%s.txt\n' "$CONFIG"
printf '• Flake cloned to /home/%s/.config/nix\n' "$USER_NAME"
