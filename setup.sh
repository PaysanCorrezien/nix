#!/usr/bin/env bash
set -e

# Uncomment the next line for debugging
set -x

# Hardcode username for now
# TODO: make this configurable here and in config ?
# maybe write this to a fil that the flake read  for the username ?
USER_NAME="dylan"

# Function to prompt for password using dialog
get_password() {
    if ! command -v dialog &> /dev/null; then
        echo "Installing dialog..."
        nix-env -iA nixos.dialog &> /dev/null;
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
    echo "$((i+1))) ${CONFIGS[i]}"
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

echo "Setting up the disk"
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake "$TEMP_REPO_DIR"#$CONFIG --no-write-lock-file

echo "Installing NixOS with configuration: $CONFIG"
sudo nixos-install --flake "$TEMP_REPO_DIR"#$CONFIG --show-trace

FINAL_REPO_DIR="/mnt/home/$USER_NAME/.config/nix"
echo "Moving configuration repository to $FINAL_REPO_DIR..."
sudo mkdir -p "$(dirname "$FINAL_REPO_DIR")"
sudo mv "$TEMP_REPO_DIR" "$FINAL_REPO_DIR"

# Set passwords for the installed system
echo "Setting passwords in the new system"
sudo nixos-enter --root /mnt <<EOF
# Set passwords
echo "debug inside nix system : $USER_PASSWORD "
echo "$USER_NAME:$USER_PASSWORD" | chpasswd
echo "root:$USER_PASSWORD" | chpasswd

#TEST: maybe its useless
chown -R "$USER_NAME:$USER_NAME" "/home/$USER_NAME/.config"
EOF

# Clean up temporary directory
rm -rf "$TEMP_REPO_DIR"

echo "Installation complete. Please reboot into your new system."
echo "You can now log in as $USER_NAME or root with the password you set."
echo "Your NixOS configuration has been cloned to /home/$USER_NAME/.config/nix"
#TODO: auto ssh key gen ?
