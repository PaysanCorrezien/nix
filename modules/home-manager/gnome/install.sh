# #!/usr/bin/env bash
#
# # Ensure the script is run as root
# if [[ $EUID -ne 0 ]]; then
# 	echo "This script must be run as root!"
# 	exit 1
# fi
#
# # Variables
# REPO_URL="https://github.com/PaysanCorrezien/nix"
# FLAKE_DIR="$HOME/.config/nix"
# SYMLINK_TARGET="$HOME/.hardware-config-link.nix"
#
# # Check for git and install if not present
# if ! command -v git &>/dev/null; then
# 	echo "Git is not installed. Installing git..."
# 	nix-env -iA nixpkgs.git
# fi
#
# # Function to clear user-specific config that might conflict
# clear_user_configs() {
# 	rm -f ~/.mozilla/firefox/profiles.ini
# 	rm -rf ~/.gtkrc-*
# 	rm -rf ~/.config/gtk-*
# 	rm -rf ~/.config/cava
# }
#
# # Clone the flake repository
# clone_repo() {
# 	echo "Cloning flake repository..."
# 	git clone $REPO_URL $FLAKE_DIR
# }
#
#
# # Setup hardware configuration symlink
# setup_hardware_config() {
# 	local hw_config="/etc/nixos/hardware-configuration.nix"
#
# 	if [ ! -f "$hw_config" ]; then
# 		echo "Generating hardware configuration..."
# 		nixos-generate-config --root /mnt
# 		cp /mnt/etc/nixos/hardware-configuration.nix /etc/nixos/
# 	fi
#
# 	echo "Creating symlink for hardware configuration at $SYMLINK_TARGET"
# 	ln -sfn "$hw_config" "$SYMLINK_TARGET"
# }
#
# # Prompt user to select the environment type
# select_environment() {
# 	echo "Available environments: 1) Home 2) Work 3) Gaming"
# 	read -p "Enter the number of your environment: " env_choice
#
# 	case $env_choice in
# 	1)
# 		env_type="home"
# 		;;
# 	2)
# 		env_type="work"
# 		;;
# 	3)
# 		env_type="gaming"
# 		;;
# 	*)
# 		echo "Invalid choice. Exiting."
# 		exit 1
# 		;;
# 	esac
# }
#
# # Main function to orchestrate setup
# main() {
# 	clear
# 	echo "Setting up your NixOS environment..."
# 	clear_user_configs
# 	clone_repo
# 	setup_hardware_config
# 	select_environment
#
# 	# Execute NixOS rebuild with the selected environment
# 	echo "Building NixOS configuration for $env_type..."
# 	sudo -u $(logname) nixos-rebuild switch --flake "$FLAKE_DIR#$env_type" --show-trace
# 	echo "Setup complete!"
# }
#
# main
