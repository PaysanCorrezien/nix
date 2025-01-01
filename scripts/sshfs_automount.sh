#!/usr/bin/env bash
# sshfs_automount.sh
#
# Description:
#   This script provides an interactive way to mount remote directories using SSHFS.
#   It uses fzf for host selection, automatically determines the appropriate username,
#   and prints the path of the mounted directory for easy access.
#
# Usage:
#   ./sshfs_automount.sh
#
# Dependencies:
#   - fzf: for interactive host selection
#   - sshfs: for mounting remote directories
#   - ssh: for querying SSH configurations
#
# Notes:
#   - Ensure you have SSH key-based authentication set up for passwordless login.
#   - The script creates mount points in ~/mount/ directory.
#   - It reads known hosts from both ~/.ssh/known_hosts and ~/.ssh/config.
#   - After successful mount, it prints the path of the mounted directory.

# Function to get known hosts
get_known_hosts() {
	if [[ -f ~/.ssh/known_hosts ]]; then
		awk '{print $1}' ~/.ssh/known_hosts | sort | uniq
	fi
	if [[ -f ~/.ssh/config ]]; then
		awk '/^Host / {print $2}' ~/.ssh/config
	fi
}

# Function to get username for a host
get_username_for_host() {
	local host=$1
	local username

	# Check if there's a specific User directive in SSH config
	username=$(ssh -G "$host" | awk '$1 == "user" && NR > 2 {print $2; exit}')

	# If no specific username found, prompt the user
	if [[ -z $username ]]; then
		read -p "👤 Enter username for $host (leave blank for $USER): " manual_username
		username=${manual_username:-$USER}
	else
		echo "👀 Found username '$username' in SSH config. Use this? (y/n)"
		read -r response
		if [[ "$response" =~ ^([nN][oO]|[nN])$ ]]; then
			read -p "👤 Enter username for $host: " manual_username
			username=${manual_username:-$USER}
		fi
	fi

	echo "$username"
}

# Main function
sshfs_automount() {
	# Create mount directory if it doesn't exist
	mkdir -p ~/mount

	# Get list of known hosts
	known_hosts=$(get_known_hosts)

	# Use fzf to select host
	selected_host=$(echo "$known_hosts" | fzf --prompt="🔍 Select host to mount: ")

	if [ -z "$selected_host" ]; then
		echo "❌ No host selected. Exiting."
		return 1
	fi

	# Get username for the selected host
	username=$(get_username_for_host "$selected_host")

	# Prompt for the remote path
	read -p "📁 Enter the remote path to mount (leave blank for home directory): " remote_path
	remote_path=${remote_path:-""} # Empty string for home directory

	# Create mount point
	mount_point=~/mount/${selected_host//[.:]/\_}
	mkdir -p "$mount_point"

	# Mount using sshfs
	if [ -z "$remote_path" ]; then
		sshfs_command="sshfs ${username}@${selected_host}: ${mount_point}"
	else
		sshfs_command="sshfs ${username}@${selected_host}:${remote_path} ${mount_point}"
	fi

	echo "🚀 Executing: $sshfs_command"
	$sshfs_command

	if [ $? -eq 0 ]; then
		echo "🔥 Successfully mounted the directory to:"
		echo "${mount_point}"
		echo
	else
		echo "❌ Failed to mount ${selected_host}"
		echo "⚠️ Error message: $(sshfs ${username}@${selected_host}:${remote_path} ${mount_point} 2>&1)"
		rmdir "$mount_point"
	fi
}

# Run the function
sshfs_automount
