# Configuration
homeManagerBackupFileExtension="HomeManagerBAK"
defaultFlakePath="/home/dylan/.config/nix"

# Function to get the current repository path using Git
get_current_repo_path() {
	if command -v git &>/dev/null; then
		git rev-parse --show-toplevel 2>/dev/null
	else
		echo ""
	fi
}

# Delete all backup files
echo "Deleting backup files with extension .$homeManagerBackupFileExtension that prevent home manager rebuild"
find ~ -type f -name "*.$homeManagerBackupFileExtension" -delete

# Determine flake path and name
flakePath=$(get_current_repo_path)
if [ -z "$flakePath" ]; then
	flakePath=$defaultFlakePath
fi

# TEST: on first build would this work since hostname is not defined ?
computerName=$(hostname)
flakeName="${flakePath}#${computerName}"

# Capture and print the rebuild command
rebuildCommand="sudo nixos-rebuild switch --flake \"$flakeName\" --impure --show-trace"
echo "Rebuilding now with command: $rebuildCommand"

# Rebuild
if eval "$rebuildCommand"; then
	echo "Rebuild successful"
else
	echo "Rebuild failed"
	exit 1
fi

echo "restarting home manager now"
systemctl restart home-manager-dylan.service
