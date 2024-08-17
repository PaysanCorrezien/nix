#!/usr/bin/env bash
set -e

# Uncomment the next line for debugging
# set -x

# Function to prompt for password
get_password() {
    local password=""
    read -s -p "Enter password for $1 (leave blank to skip): " password
    echo
    if [ -n "$password" ]; then
        local password2=""
        read -s -p "Confirm password: " password2
        echo
        if [ "$password" = "$password2" ]; then
            echo "$password"
        else
            echo "Passwords do not match. Skipping password setting."
            echo ""
        fi
    else
        echo ""
    fi
}

# Prompt for username with default
read -p "Enter username (default: dylan): " USER_NAME
USER_NAME=${USER_NAME:-dylan}

# Set user and root password early
USER_PASSWORD=$(get_password "user $USER_NAME and root")

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

# Only set passwords if a password was provided
if [ -n "$USER_PASSWORD" ]; then
    echo "Creating user $USER_NAME and setting passwords in the new system"
    sudo nixos-enter <<EOF
    # Create user if it doesn't exist
    if ! id "$USER_NAME" &>/dev/null; then
        useradd -m -s /bin/bash "$USER_NAME"
        # Add user to wheel group for sudo access
        usermod -aG wheel "$USER_NAME"
    fi

    # Set passwords
    echo "$USER_NAME:$USER_PASSWORD" | chpasswd
    echo "root:$USER_PASSWORD" | chpasswd
EOF
else
    echo "No password provided. Skipping password setting."
fi

# Clone the repository to the user's .config/nix directory in the installed system
FINAL_REPO_DIR="/mnt/home/$USER_NAME/.config/nix"
echo "Cloning configuration repository to $FINAL_REPO_DIR..."
sudo mkdir -p "$FINAL_REPO_DIR"
sudo git clone "$REPO_URL" "$FINAL_REPO_DIR"
sudo chown -R "$USER_NAME:$USER_NAME" "/mnt/home/$USER_NAME/.config"

# Clean up temporary directory
rm -rf "$TEMP_REPO_DIR"

echo "Installation complete. Please reboot into your new system."
if [ -n "$USER_PASSWORD" ]; then
    echo "You can now log in as $USER_NAME or root with the password you set."
else
    echo "No password was set. You may need to set passwords after booting into your new system."
fi
echo "Your NixOS configuration has been cloned to /home/$USER_NAME/.config/nix"
