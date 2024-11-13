#!/usr/bin/env bash
set -e

# Uncomment the next line for debugging
set -x
# TODO: allow passing argument for password, host, username
# Hardcode username for now
# TODO: make this configurable here and in config ?
# maybe write this to a fil that the flake read  for the username ?
USER_NAME="dylan"

# Function to prompt for password using dialog
get_password() {
	if ! command -v dialog &>/dev/null; then
		nix-env -iA nixos.dialog &>/dev/null
	fi
	password=$(dialog --passwordbox "Enter password for $USER_NAME:" 0 0 2>&1 >/dev/tty)
	echo "$password"
}

# Set user password early
USER_PASSWORD=$(get_password)

# Debug output (comment out for production use)
echo "Debug: Username is $USER_NAME"
echo "Debug: Password is $USER_PASSWORD"

# Clean up existing temporary directory if it exists
TEMP_REPO_DIR="/tmp/nixos-config"
if [ -d "$TEMP_REPO_DIR" ]; then
	echo "Removing existing temporary directory..."
	rm -rf "$TEMP_REPO_DIR"
fi

# Install necessary packages
echo "Installing required packages..."
nix-env -iA nixos.git nixos.fzf

# Clone the repository to a temporary location
REPO_URL="https://github.com/paysancorrezien/nix.git"
echo "Cloning configuration repository..."
git clone "$REPO_URL" "$TEMP_REPO_DIR"

# Get available configurations
echo "Fetching available NixOS configurations..."
CONFIGS=($(ls "$TEMP_REPO_DIR"/hosts/*.nix | xargs -n1 basename | sed 's/\.nix$//'))
if [ ${#CONFIGS[@]} -eq 0 ]; then
	echo "No NixOS configurations found in the hosts directory."
	exit 1
fi

# Present available configurations
echo "Available NixOS configurations:"
for i in "${!CONFIGS[@]}"; do
	echo "$((i + 1))) ${CONFIGS[i]}"
done

# Use fzf to select configuration
echo "Please select a configuration using fzf:"
CONFIG=$(printf '%s\n' "${CONFIGS[@]}" | fzf --height=10 --layout=reverse --prompt="Select configuration > ")
if [ -z "$CONFIG" ]; then
	echo "No configuration selected. Exiting."
	exit 1
fi

echo "You selected: $CONFIG"
echo "Installing NixOS with configuration: $CONFIG"

# Age key management
AGE_KEY_TEMP=$(find /tmp -maxdepth 1 -name "*.age" | head -n 1)
if [ -n "$AGE_KEY_TEMP" ]; then
	echo "Age key found: $AGE_KEY_TEMP"
	AGE_KEY_DEST="/mnt/var/secrets/${CONFIG}.age"
	echo "Age key will be moved to: $AGE_KEY_DEST"
else
	echo "No Age key found in /tmp. Skipping Age key setup."
fi

# Run the disk selector and capture its output
#FIX:  this make detect a prompt and either use the provide disk of current system or auto install
#FIX : currently deebut disk from diskselect is not working anymore
# DISK_INFO=$(nix-instantiate --eval -E "let diskSelect = import $TEMP_REPO_DIR/diskselect.nix { inherit (import <nixpkgs> {}) lib; }; in diskSelect.debugInfo" --json | sed 's/^"//;s/"$//')
#
# # Extract the selected drive from the disk info
# SELECTED_DRIVE=$(echo "$DISK_INFO" | grep "Selected drive:" | awk '{print $NF}')
#
# echo "Disk Information:"
# echo "$DISK_INFO"
# echo
# echo "Selected drive for installation: $SELECTED_DRIVE"
# echo

# Confirmation prompt using fzf
CONFIRMATION=$(echo -e "Yes\nNo" | fzf --prompt="Do you want to proceed with the installation on $SELECTED_DRIVE? " --height=20%)

if [[ $CONFIRMATION != "Yes" ]]; then
	echo "Installation aborted."
	exit 1
fi

echo "Setting up the disk"
#TODO: find a way to not ever again rely again on the git master which is always
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode disko --flake "$TEMP_REPO_DIR"#$CONFIG --no-write-lock-file
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --flake "$TEMP_REPO_DIR"#$CONFIG --no-write-lock-file

echo "Installing NixOS with configuration: $CONFIG"
#TEST: capture output for debug, and --impure seems mandatory for laptop?
(
	sudo nixos-install --flake "$TEMP_REPO_DIR"#$CONFIG --show-trace --impure > >(tee /tmp/nixos-install.log) 2>&1 &
	echo $! >/tmp/nixos-install.pid
)
echo "Installation started in the background. You can monitor the progress in /tmp/nixos-install.log"
echo "Waiting for installation to complete..."
wait $(cat /tmp/nixos-install.pid)
# FIX: this never get run we never reach here
echo "Installation completed"

FINAL_REPO_DIR="/mnt/home/$USER_NAME/.config/nix"
echo "Moving configuration repository to $FINAL_REPO_DIR..."
sudo mkdir -p "$(dirname "$FINAL_REPO_DIR")"
#FIX:: move this properly
sudo mv "$TEMP_REPO_DIR" "$FINAL_REPO_DIR"

# Move and rename Age key to the installed system
if [ -n "$AGE_KEY_TEMP" ]; then
	echo "Moving Age key to the installed system..."
	sudo mkdir -p "$(dirname "$AGE_KEY_DEST")"
	sudo mv "$AGE_KEY_TEMP" "$AGE_KEY_DEST"
	echo "Age key moved, renamed to ${CONFIG}.age, and permissions set."
fi

# Set passwords for the installed system
echo "Setting passwords in the new system"
sudo nixos-enter --root /mnt <<EOF
# Set passwords
echo "debug inside nix system : $USER_PASSWORD "
echo "$USER_NAME:$USER_PASSWORD" | chpasswd
echo "root:$USER_PASSWORD" | chpasswd
 Set permissions for the Age key
if [ -f "$AGE_KEY_DEST" ]; then
    chmod 600 "$AGE_KEY_DEST"
    chown root:root "$AGE_KEY_DEST"
    echo "Age key permissions and ownership set."
fi

#TEST: maybe its useless
#FIXME: not properly set atm?
chown -R "$USER_NAME:users" "/home/$USER_NAME/.config"
EOF

# Clean up temporary directory
rm -rf "$TEMP_REPO_DIR"

# Add this at the end of your script
if [ -f "$AGE_KEY_DEST" ]; then
	echo "Age key has been placed at $AGE_KEY_DEST in the new system"
fi

echo "Installation complete. Please reboot into your new system."
echo "You can now log in as $USER_NAME or root with the password you set."
echo "Your NixOS configuration has been cloned to /home/$USER_NAME/.config/nix"
#TODO: auto ssh key gen ?
