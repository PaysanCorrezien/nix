#!/usr/bin/env bash
set -e

# Function to prompt for password
get_password() {
	while true; do
		read -s -p "Enter password for $1: " password
		echo
		read -s -p "Confirm password: " password2
		echo
		[ "$password" = "$password2" ] && break
		echo "Passwords do not match. Please try again."
	done
	echo "$password"
}

# Install necessary packages
echo "Installing required packages..."
nix-env -iA nixos.git

# Prompt for username with default
read -p "Enter username (default: dylan): " USER_NAME
USER_NAME=${USER_NAME:-dylan}

# Clone the repository to a temporary location
REPO_URL="https://github.com/paysancorrezien/nix.git"
TEMP_REPO_DIR="/tmp/nixos-config"
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
select CONFIG in "${CONFIGS[@]}"; do
	if [ -n "$CONFIG" ]; then
		break
	else
		echo "Invalid selection. Please try again."
	fi
done

echo "Setting up the disk"
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake "$TEMP_REPO_DIR"#$CONFIG --no-write-lock-file

echo "Installing NixOS with configuration: $CONFIG"
sudo nixos-install --flake "$TEMP_REPO_DIR"#$CONFIG --no-write-lockfile --show-trace --no-root-password

# Set user and root password
USER_PASSWORD=$(get_password "user $USER_NAME and root")

# Set passwords for the installed system
echo "Setting password for user $USER_NAME in the new system"
echo "$USER_NAME:$USER_PASSWORD" | sudo chpasswd -R /mnt

echo "Setting root password in the new system"
echo "root:$USER_PASSWORD" | sudo chpasswd -R /mnt

# Clone the repository to the user's .config/nix directory in the installed system
FINAL_REPO_DIR="/mnt/home/$USER_NAME/.config/nix"
echo "Cloning configuration repository to $FINAL_REPO_DIR..."
sudo mkdir -p "$FINAL_REPO_DIR"
sudo git clone "$REPO_URL" "$FINAL_REPO_DIR"
sudo chown -R 1000:1000 "/mnt/home/$USER_NAME/.config"

# Clean up temporary directory
rm -rf "$TEMP_REPO_DIR"

echo "Installation complete. Please reboot into your new system."
echo "You can now log in as $USER_NAME or root with the password you set."
echo "Your NixOS configuration has been cloned to /home/$USER_NAME/.config/nix"
