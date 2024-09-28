# Configuration
homeManagerBackupFileExtension="HomeManagerBAK"
defaultFlakePath="/home/dylan/.config/nix"

echo "🚀 Starting Nix rebuild process..."

if [ "$PWD" != "$HOME/.config/nix" ]; then
	echo "📂 Changing directory to $HOME/.config/nix"
	cd "$HOME/.config/nix" || {
		echo "❌ Failed to change directory. Exiting."
		exit 1
	}
fi

# Function to get the current repository path using Git
get_current_repo_path() {
	if command -v git &>/dev/null; then
		git rev-parse --show-toplevel 2>/dev/null
	else
		echo ""
	fi
}

# Function to check network access
check_network_access() {
	echo "🌐 Checking network connectivity..."
	if ping -c 1 google.com &>/dev/null; then
		echo "✅ Network is accessible"
		return 0
	else
		echo "❌ No network access"
		return 1
	fi
}

# Function to check Git status and prompt for pull
check_git_status_and_pull() {
	local repo_path="$1"
	echo "🔍 Checking Git status for $repo_path"
	if [ ! -d "$repo_path/.git" ]; then
		echo "⚠️ Warning: $repo_path is not a Git repository."
		return 1
	fi
	if check_network_access; then
		if git -C "$repo_path" fetch &>/dev/null; then
			# -C run in a specific directory
			# The -uno option stands for --untracked-files=no
			local status=$(git -C "$repo_path" status -uno)
			if echo "$status" | grep -qE "(Your branch is behind|Votre branche est en retard)"; then
				echo "📥 There are changes available on the remote repository for $repo_path."
				read -p "Do you want to pull the latest changes? (y/n): " answer
				if [ "$answer" = "y" ]; then
					echo "🔄 Pulling latest changes..."
					git -C "$repo_path" pull
					echo "✅ Pull complete"
				else
					echo "⏭️ Skipping pull"
				fi
			else
				echo "✅ Repository is up to date"
			fi
		else
			echo "❌ Failed to fetch from remote"
		fi
	fi
}

# Determine flake path
flakePath="$defaultFlakePath"
echo "📁 Using flake path: $flakePath"
if [ ! -d "$flakePath" ]; then
	echo "❌ Error: Flake directory $flakePath does not exist."
	exit 1
fi

# Check Git status and prompt for pull if changes are available
check_git_status_and_pull "$flakePath"

echo "🧹 Deleting backup files with extension .$homeManagerBackupFileExtension that prevent home manager rebuild"
find ~ -type f -name "*.$homeManagerBackupFileExtension" -delete
echo "✅ Cleanup complete"

computerName=$(hostname)
flakeName="${flakePath}#${computerName}"
echo "💻 Computer name: $computerName"
echo "🏷️ Flake name: $flakeName"

# Capture and print the rebuild command
rebuildCommand="sudo nixos-rebuild switch --flake \"$flakeName\" --impure --show-trace"
echo "🛠️ Rebuilding now with command:"
echo "$rebuildCommand"

# Rebuild
echo "🔨 Starting rebuild process..."
if eval "$rebuildCommand"; then
	echo "✅ Rebuild successful"
else
	echo "❌ Rebuild failed"
	exit 1
fi

echo "🔄 Restarting home manager now"
sudo systemctl restart home-manager-dylan.service
echo "✅ Home manager restarted"

echo "🔄 Running Chezmoi update"
$HOME/.local/bin/update-dotfiles "https://github.com/PaysanCorrezien/dotfiles"
echo "✅ Chezmoi update complete"

echo "🎉 All processes completed successfully!"
