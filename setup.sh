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
	echo ""
	echo "Available partitions (size, label, type, mount):"
	lsblk -rpno NAME,SIZE,LABEL,TYPE,MOUNTPOINT | awk '$4=="part" {printf "  %s (%s) %s %s\n", $1, $2, ($3==""?"-":$3), ($5==""?"":$5)}'
	echo ""
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

run_sudo() {
	if [[ "$(id -u)" -eq 0 ]]; then
		"$@"
		return
	fi
	if command -v sudo >/dev/null 2>&1; then
		sudo "$@"
		return
	fi
	echo "Error: sudo not available and not running as root."
	exit 1
}

# ---------------------------------------------------------------------------- #
# Preflight: add zram swap to increase effective memory for nix builds          #
# This helps when the live ISO's /nix/store (tmpfs) runs low on space           #
# ---------------------------------------------------------------------------- #
echo "Setting up zram swap for additional memory..."
if run_sudo modprobe zram 2>/dev/null; then
	# Use 50% of RAM as compressed swap (effectively ~2x that due to compression)
	mem_kb=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
	zram_size_kb=$((mem_kb / 2))
	echo "${zram_size_kb}K" | run_sudo tee /sys/block/zram0/disksize >/dev/null 2>&1 || true
	run_sudo mkswap /dev/zram0 >/dev/null 2>&1 || true
	run_sudo swapon -p 100 /dev/zram0 2>/dev/null || true
	echo "✓ zram swap enabled ($(( zram_size_kb / 1024 ))MB compressed)"
else
	echo "⚠️  zram not available, continuing without extra swap"
fi

# ---------------------------------------------------------------------------- #
# Ensure dependencies                                                          #
# ---------------------------------------------------------------------------- #
echo "Installing git, fzf, and coreutils …"
# Use separate nix‑env calls without -q; some installer shells reject combined flags.
nix-env -iA nixos.git
nix-env -iA nixos.fzf
nix-env -iA nixos.coreutils
export PATH="/run/current-system/sw/bin:$PATH"

# ---------------------------------------------------------------------------- #
# Prepare workspace                                                            #
# ---------------------------------------------------------------------------- #
[ -d "$TEMP_REPO_DIR" ] && {
	echo "Removing $TEMP_REPO_DIR"
	run_sudo /run/current-system/sw/bin/rm -rf "$TEMP_REPO_DIR"
}

git clone --depth 1 "$REPO_URL" "$TEMP_REPO_DIR"

# ---------------------------------------------------------------------------- #
# Pick host                                                                    #
# ---------------------------------------------------------------------------- #
shopt -s nullglob
HOST_FILES=("$TEMP_REPO_DIR"/hosts/*.nix)
shopt -u nullglob
((${#HOST_FILES[@]})) || {
	echo "No host files"
	exit 1
}
mapfile -t CONFIGS < <(printf '%s\n' "${HOST_FILES[@]}" | xargs -n1 basename | sed 's/\.nix$//')
CONFIG=$(printf '%s\n' "${CONFIGS[@]}" | fzf --height 10 --layout=reverse --prompt="Select host > " || true)
[ -z "$CONFIG" ] && {
	echo "Cancelled"
	exit 1
}

echo "Host → $CONFIG"

# ---------------------------------------------------------------------------- #
# Optional Age key import                                                      #
# ---------------------------------------------------------------------------- #
KEY_SOURCE=""
echo ""
echo "SOPS/Age key import:"
echo "- If you have an existing Age key on a USB drive, you can import it now."
echo "- This lets the installer decrypt secrets during install."
echo "- You can also skip and add the key later."
echo ""
KEY_CHOICE=$(printf 'Skip\nImport from external drive\n' | fzf --height 4 --prompt="Import Age key? > " || true)
case "$KEY_CHOICE" in
"Import from external drive")
	PART=$(choose_partition) || { echo "No partition chosen → skipping key import"; }
	if [[ -n "$PART" ]]; then
		echo "Mounting $PART on $MOUNT_TMP …"
		run_sudo mkdir -p "$MOUNT_TMP"
		run_sudo mount "$PART" "$MOUNT_TMP"
		trap 'run_sudo umount "$MOUNT_TMP" >/dev/null 2>&1 || true' EXIT
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
run_sudo nix --experimental-features "nix-command flakes" run \
	github:nix-community/disko/latest -- \
	--mode disko --flake "$TEMP_REPO_DIR#$CONFIG" --no-write-lock-file

# ---------------------------------------------------------------------------- #
# Copy key into target root                                                    #
# ---------------------------------------------------------------------------- #
if [[ -n "$KEY_SOURCE" ]]; then
	DEST_KEY="/mnt/var/lib/secrets/${CONFIG}.txt"
	echo "Copying → $DEST_KEY"
	run_sudo mkdir -p "$(dirname "$DEST_KEY")"
	run_sudo install -m 600 "$KEY_SOURCE" "$DEST_KEY"
fi

# ---------------------------------------------------------------------------- #
# nixos-install                                                                #
# ---------------------------------------------------------------------------- #
ENV_ARGS=()
[[ -n "$KEY_SOURCE" ]] && ENV_ARGS+=("SOPS_AGE_KEY_FILE=/var/lib/secrets/${CONFIG}.txt")

echo "Running nixos-install …"
# shellcheck disable=SC2048,SC2068
run_sudo ${ENV_ARGS[*]} nixos-install --flake "$TEMP_REPO_DIR#$CONFIG" --show-trace --impure

# ---------------------------------------------------------------------------- #
# Copy flake into installed system                                             #
# ---------------------------------------------------------------------------- #
FINAL_REPO_DIR="/mnt/home/$USER_NAME/.config/nix"
run_sudo mkdir -p "$(dirname "$FINAL_REPO_DIR")"
run_sudo mv "$TEMP_REPO_DIR" "$FINAL_REPO_DIR"
# Use UID 1000 since the user doesn't exist on live ISO, only in installed system
run_sudo chown -R 1000:1000 "$FINAL_REPO_DIR"

# ---------------------------------------------------------------------------- #
# Cleanup                                                                      #
# ---------------------------------------------------------------------------- #
[ -d "$TEMP_REPO_DIR" ] && rm -rf "$TEMP_REPO_DIR"
trap - EXIT
[[ -n "${PART:-}" ]] && run_sudo umount "$MOUNT_TMP" >/dev/null 2>&1 || true

echo -e "\n✅ Installation complete. Reboot now."
[[ -n "$KEY_SOURCE" ]] && printf '• Age key copied to /var/lib/secrets/%s.txt\n' "$CONFIG"
printf '• Flake cloned to /home/%s/.config/nix\n' "$USER_NAME"
