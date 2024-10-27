# Configuration
homeManagerBackupFileExtension="HomeManagerBAK"
defaultFlakePath="/home/dylan/.config/nix"

# Global variable for network status
NETWORK_AVAILABLE=false

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
		NETWORK_AVAILABLE=true
		return 0
	else
		echo "❌ No network access"
		NETWORK_AVAILABLE=false
		return 1
	fi
}

check_git_status_and_pull() {
	local repo_path="$1"
	echo "🔍 Checking Git status for $repo_path"
	if [ ! -d "$repo_path/.git" ]; then
		echo "⚠️ Warning: $repo_path is not a Git repository."
		return 1
	fi
	if $NETWORK_AVAILABLE; then
		if git -C "$repo_path" fetch &>/dev/null; then
			local status=$(git -C "$repo_path" status -uno)
			if echo "$status" | grep -qE "(Your branch is behind|Votre branche est en retard)"; then
				echo "📥 There are changes available on the remote repository for $repo_path."

				# Get the range of commits to be pulled
				local current_branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)
				local remote_branch="origin/$current_branch"
				local commit_range="$current_branch..$remote_branch"

				# Display commit information
				echo "Commits to be pulled:"
				git -C "$repo_path" log --pretty=format:"%h - %s (%cr) <%an>" --abbrev-commit --date=relative $commit_range |
					while IFS= read -r line; do
						commit_hash=$(echo $line | cut -d' ' -f1)
						commit_stats=$(git -C "$repo_path" show --stat --oneline $commit_hash | tail -n 1)
						echo "$line"
						echo "    $commit_stats"
						echo
					done

				read -p "Do you want to pull the latest changes? (y/n): " answer
				if [ "$answer" = "y" ]; then
					echo "🔄 Attempting to pull latest changes..."
					if ! git -C "$repo_path" pull; then
						echo "❌ Pull failed. You have uncommitted changes."
						git -C "$repo_path" status
						echo "Uncommitted changes:"
						git -C "$repo_path" diff
						while true; do
							echo "Choose an action:"
							echo "1) Commit changes"
							echo "2) Stash changes"
							echo "3) Discard changes"
							echo "4) Skip pull"
							read -p "Enter your choice (1-4): " choice
							case $choice in
							1)
								read -p "Enter commit message: " commit_msg
								git -C "$repo_path" commit -am "$commit_msg"
								git -C "$repo_path" pull
								break
								;;
							2)
								git -C "$repo_path" stash
								git -C "$repo_path" pull
								git -C "$repo_path" stash pop
								break
								;;
							3)
								git -C "$repo_path" reset --hard
								git -C "$repo_path" clean -fd
								git -C "$repo_path" pull
								break
								;;
							4)
								echo "⏭️ Skipping pull"
								break
								;;
							*)
								echo "Invalid choice. Please try again."
								;;
							esac
						done
					fi
					echo "✅ Pull process complete"
				else
					echo "⏭️ Skipping pull"
				fi
			else
				echo "✅ Repository is up to date"
			fi
		else
			echo "❌ Failed to fetch from remote"
		fi
	else
		echo "⚠️ No network access. Skipping Git operations."
	fi
}

dump_metadata() {
	local repo_path="$1"
	local config_name="${2:-$(hostname)}"
	local output_dir="$HOME/.local/share/nix-metadata"
	local output_file="$output_dir/latest_build_metadata.json"

	# Collect git information
	local git_info
	git_info=$(
		cat <<EOF
{
    "commit_id": "$(git -C "$repo_path" rev-parse HEAD)",
    "commit_count": $(git -C "$repo_path" rev-list --count HEAD),
    "commit_message": $(git -C "$repo_path" log -1 --pretty=%B | jq -R -s .),
    "branch": "$(git -C "$repo_path" rev-parse --abbrev-ref HEAD)"
}
EOF
	)

	# Get nix store path
	local nix_store_path
	nix_store_path=$(nix build --no-link --print-out-paths \
		--system "$(nix eval --impure --expr 'builtins.currentSystem')" \
		"$repo_path#nixosConfigurations.$config_name.config.system.build.toplevel" 2>/dev/null) ||
		nix_store_path=$(readlink -f /run/current-system || echo "unknown")

	# Create output directory
	mkdir -p "$output_dir"

	# Generate metadata JSON
	cat <<EOF >"$output_file"
{
    "build_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "hostname": "$(hostname)",
    "nixos_version": "$(nixos-version)",
    "git_info": $git_info,
    "flake_path": "$repo_path",
    "flake_name": "$repo_path#$config_name",
    "nix_store_path": "$nix_store_path"
}
EOF

	# Print success message for metadata dump
	echo "✅ Metadata dumped to $output_file"

	# Get and display settings
	local settings_data
	settings_data=$(nix eval --json --accept-flake-config \
		"$repo_path#nixosConfigurations.$config_name.config.settings" 2>/dev/null)

	if [ $? -eq 0 ]; then
		echo -e "\n📋 Current System Settings:"
		echo "──────────────────────────"
		# Option 1: Using rich-cli
		echo "$settings_data" | rich - --json --theme monokai

		# Option 2: Using gum (uncomment if you prefer gum)
		# echo "$settings_data" | jq '.' | sed 's/: true/: ✓/g' | sed 's/: false/: ✗/g' | gum style --foreground 212

		# Option 3: Using bat (uncomment if you prefer bat)
		# echo "$settings_data" | bat -l json --plain

		echo "──────────────────────────"
	else
		echo "❌ Failed to retrieve system settings"
	fi
}

# Determine flake path
flakePath="$defaultFlakePath"
echo "📁 Using flake path: $flakePath"
if [ ! -d "$flakePath" ]; then
	echo "❌ Error: Flake directory $flakePath does not exist."
	exit 1
fi

# Check network access
check_network_access

# Check Git status and prompt for pull if changes are available (only if network is available)
if $NETWORK_AVAILABLE; then
	check_git_status_and_pull "$flakePath"
else
	echo "⚠️ No network access. Skipping Git operations."
fi

echo "🧹 Deleting backup files with extension .$homeManagerBackupFileExtension that prevent home manager rebuild"
find ~ -type f -name "*.$homeManagerBackupFileExtension" -delete
echo "✅ Cleanup complete"

computerName=$(hostname)
flakeName="${flakePath}#${computerName}"
echo "💻 Computer name: $computerName"
echo "🏷️ Flake name: $flakeName"

# Capture and print the rebuild command
rebuildCommand="sudo nixos-rebuild switch --flake \"$flakeName\" --impure --show-trace"
if ! $NETWORK_AVAILABLE; then
	rebuildCommand+=" --option substitute false"
	echo "⚠️ Running in offline mode. Binary substitutions disabled."
fi
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

if $NETWORK_AVAILABLE; then
	echo "🔄 Running Chezmoi update"
	$HOME/.local/bin/update-dotfiles "https://github.com/PaysanCorrezien/dotfiles"
	echo "✅ Chezmoi update complete"
else
	echo "⚠️ Skipping Chezmoi update due to no network access"
fi
echo "📝 Dumping build metadata..."
dump_metadata "$flakePath"

echo "🎉 All processes completed successfully!"
