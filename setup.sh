#!/usr/bin/env bash
set -euo pipefail
# set -x   # Uncomment for verbose tracing

################################################################################
# NixOS unattended installer
#
# • Pick host with fzf
# • Optionally mount an external block‑device, select an Age/SOPS key
# • Run disko, nixos-install
# • Copy flake into /home/<user>/.config/nix
################################################################################

# ---------------------------------------------------------------------------- #
# Settings                                                                     #
# ---------------------------------------------------------------------------- #
USER_NAME=${USER_NAME:-"dylan"}
REPO_URL=${REPO_URL:-"https://github.com/paysancorrezien/nix.git"}
TEMP_REPO_DIR="/tmp/nixos-config"
MOUNT_TMP="/mnt/agekey"

# ---------------------------------------------------------------------------- #
# Helpers                                                                      #
# ---------------------------------------------------------------------------- #

choose_partition() {
	mapfile -t PARTS < <(
		lsblk -rpno NAME,SIZE,LABEL,TYPE,MOUNTPOINT | awk '$4=="part" {printf "%s (%s) %s %s\n", $1, $2, ($3==""?"-":$3), ($5==""?"":$5)}'
	)
	((${#PARTS[@]})) || return 1
	printf '%s\n' "${PARTS[@]}" | fzf --height 15 --layout=reverse --prompt="Select partition > " | awk '{print $1}'
}

choose_age_key() {
	local dir="$1"
	mapfile -t KEYS < <(find "$dir" -maxdepth 2 -type f \( -name '*.age' -o -name '*.txt' \))
	((${#KEYS[@]})) || return 1
	[[ ${#KEYS[@]} -eq 1 ]] && {
		printf '%s' "${KEYS[0]}"
		return 0
	}
	printf '%s\n' "${KEYS[@]}" | fzf --height 10 --layout=reverse --prompt="Select Age key > "
}

# ---------------------------------------------------------------------------- #
# Ensure dependencies                                                          #
# ---------------------------------------------------------------------------- #
echo "Installing git and fzf …"
# Use separate nix‑env calls without -q; some installer shells reject combined flags.
nix-env -iA nixos.git
nix-env -iA nixos.fzf

# ---------------------------------------------------------------------------- #
# Prepare workspace                                                            #
# ---------------------------------------------------------------------------- #
[ -d "$TEMP_REPO_DIR" ] && {
	echo "Removing $TEMP_REPO_DIR"
	rm -rf "$TEMP_REPO_DIR"
}

git clone --depth 1 "$REPO_URL" "$TEMP_REPO_DIR"

# ---------------------------------------------------------------------------- #
# Pick host                                                                    #
# ---------------------------------------------------------------------------- #
mapfile -t CONFIGS < <(ls "$TEMP_REPO_DIR"/hosts/*.nix | xargs -n1 basename | sed 's/\.nix$//')
((${#CONFIGS[@]})) || {
	echo "No host files"
	exit 1
}
CONFIG=$(printf '%s\n' "${CONFIGS[@]}" | fzf --height 10 --layout=reverse --prompt="Select host > ")
[ -z "$CONFIG" ] && {
	echo "Cancelled"
	exit 1
}

echo "Host → $CONFIG"

# ---------------------------------------------------------------------------- #
# Optional Age key import                                                      #
# ---------------------------------------------------------------------------- #
KEY_SOURCE=""
case $(printf 'Skip\nImport from external drive\n' | fzf --height 4 --prompt="Import Age key? > ") in
"Import from external drive")
	PART=$(choose_partition) || { echo "No partition chosen → skipping key import"; }
	if [[ -n "$PART" ]]; then
		echo "Mounting $PART on $MOUNT_TMP …"
		sudo mkdir -p "$MOUNT_TMP"
		sudo mount "$PART" "$MOUNT_TMP"
		trap 'sudo umount "$MOUNT_TMP" >/dev/null 2>&1 || true' EXIT
		KEY_SOURCE=$(choose_age_key "$MOUNT_TMP" || true)
		if [[ -z "$KEY_SOURCE" ]]; then
			echo "⚠️  No key picked → continuing without Age key"
		else
			echo "Key selected: $KEY_SOURCE"
		fi
	fi
	;;
*) echo "Skipping Age key import" ;;
esac

# ---------------------------------------------------------------------------- #
# Run disko                                                                    #
# ---------------------------------------------------------------------------- #
sudo nix --experimental-features "nix-command flakes" run \
	github:nix-community/disko/latest -- \
	--mode disko --flake "$TEMP_REPO_DIR#$CONFIG" --no-write-lock-file

# ---------------------------------------------------------------------------- #
# Copy key into target root                                                    #
# ---------------------------------------------------------------------------- #
if [[ -n "$KEY_SOURCE" ]]; then
	DEST_KEY="/mnt/var/lib/secrets/${CONFIG}.txt"
	echo "Copying → $DEST_KEY"
	sudo mkdir -p "$(dirname "$DEST_KEY")"
	sudo install -m 600 "$KEY_SOURCE" "$DEST_KEY"
fi

# ---------------------------------------------------------------------------- #
# nixos-install                                                                #
# ---------------------------------------------------------------------------- #
ENV_ARGS=()
[[ -n "$KEY_SOURCE" ]] && ENV_ARGS+=("SOPS_AGE_KEY_FILE=/var/lib/secrets/${CONFIG}.txt")

echo "Running nixos-install …"
# shellcheck disable=SC2048,SC2068
sudo ${ENV_ARGS[*]} nixos-install --flake "$TEMP_REPO_DIR#$CONFIG" --show-trace --impure

# ---------------------------------------------------------------------------- #
# Copy flake into installed system                                             #
# ---------------------------------------------------------------------------- #
FINAL_REPO_DIR="/mnt/home/$USER_NAME/.config/nix"
sudo mkdir -p "$(dirname "$FINAL_REPO_DIR")"
sudo mv "$TEMP_REPO_DIR" "$FINAL_REPO_DIR"

# ---------------------------------------------------------------------------- #
# Cleanup                                                                      #
# ---------------------------------------------------------------------------- #
[ -d "$TEMP_REPO_DIR" ] && rm -rf "$TEMP_REPO_DIR"
trap - EXIT
[[ -n "${PART:-}" ]] && sudo umount "$MOUNT_TMP" >/dev/null 2>&1 || true

echo -e "\n✅ Installation complete. Reboot now."
[[ -n "$KEY_SOURCE" ]] && printf '• Age key copied to /var/lib/secrets/%s.txt\n' "$CONFIG"
printf '• Flake cloned to /home/%s/.config/nix\n' "$USER_NAME"
