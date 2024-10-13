# Check if a hostname was provided
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 <hostname>"
	exit 1
fi

REMOTE_HOST="$1"

# The path to your get_system_info.sh script
LOCAL_SCRIPT_PATH="$HOME/.config/nix/scripts/get-currentsysteminfo.sh"

# Ensure the local script exists
if [ ! -f "$LOCAL_SCRIPT_PATH" ]; then
	echo "Error: Local script not found at $LOCAL_SCRIPT_PATH"
	exit 1
fi

# Copy the script to the remote host and execute it
ssh "$REMOTE_HOST" "bash -s" <"$LOCAL_SCRIPT_PATH"
