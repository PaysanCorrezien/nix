# ANSI color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
FLAKE_DIR="$HOME/.config/nix"
REMOTE_SCRIPT="$HOME/.config/nix/scripts/get-remotesysteminfo.sh"
LOCAL_SCRIPT="$HOME/.config/nix/scripts/get-currentsysteminfo.sh"
MAX_PARALLEL=10

# Function to get system info for a single host
get_host_info() {
	local host="$1"
	local current_hostname=$(hostname)

	if [ "$host" = "$current_hostname" ]; then
		# Run local script for current host
		$LOCAL_SCRIPT
	elif ping -c 1 -W 2 "$host" &>/dev/null; then
		$REMOTE_SCRIPT "$host"
	else
		printf "${RED}💻 %-12s${NC} | ${RED}%-19s${NC} | ${RED}%-10s${NC} | ${RED}%-4s${NC} | ${RED}%-7s${NC} | ${RED}%-50s${NC}\n" \
			"$host" "Not available" "-" "-" "-" "-"
	fi
}

# Get available configurations
echo "Fetching available NixOS configurations..."
CONFIGS=($(ls "$FLAKE_DIR"/hosts/*.nix | xargs -n1 basename | sed 's/\.nix$//'))
if [ ${#CONFIGS[@]} -eq 0 ]; then
	echo "No NixOS configurations found in the hosts directory."
	exit 1
fi

# Create a temporary file to store results
RESULTS_FILE=$(mktemp)

# Process hosts in parallel
echo "Fetching system information for ${#CONFIGS[@]} hosts..."
for host in "${CONFIGS[@]}"; do
	((i = i % MAX_PARALLEL))
	((i++ == 0)) && wait
	get_host_info "$host" >>"$RESULTS_FILE" &
done
wait # Wait for all background processes to finish

# Sort and display results
sort "$RESULTS_FILE"

# Clean up
rm "$RESULTS_FILE"

echo "Done!"
