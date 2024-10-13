# ANSI color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
HOST_ICON="💻"
CLOCK_ICON="🕒"
HOURGLASS_ICON="⏳"
COMMIT_ICON="📚"
GIT_ICON="🔀"
MSG_ICON="💬"

# Get last build date and time
BUILD_INFO=$(sudo nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 1)
BUILD_DATE=$(echo $BUILD_INFO | awk '{print $2}')
BUILD_TIME=$(echo $BUILD_INFO | awk '{print $3}')

# Get system uptime
UPTIME=$(awk '{print int($1/86400)"d "int($1%86400/3600)"h "int(($1%3600)/60)"m"}' /proc/uptime)

# Read metadata file
METADATA_FILE="$HOME/.local/share/nix-metadata/latest_build_metadata.json"
if [ -f "$METADATA_FILE" ]; then
	METADATA=$(cat "$METADATA_FILE")
	COMMIT_ID=$(echo "$METADATA" | jq -r '.git_info.commit_id' | cut -c1-7)
	COMMIT_COUNT=$(echo "$METADATA" | jq -r '.git_info.commit_count')
	COMMIT_MESSAGE=$(echo "$METADATA" | jq -r '.git_info.commit_message' | tr '\n' ' ' | cut -c1-50)
	HOSTNAME=$(echo "$METADATA" | jq -r '.hostname')
else
	COMMIT_ID="N/A"
	COMMIT_COUNT="N/A"
	COMMIT_MESSAGE="N/A"
	HOSTNAME=$(hostname)
fi

# Format and output
printf "${BLUE}${HOST_ICON} %-12s${NC} | ${GREEN}${CLOCK_ICON} %-19s${NC} | ${YELLOW}${HOURGLASS_ICON} %-10s${NC} | ${CYAN}${COMMIT_ICON} %-4s${NC} | ${CYAN}${GIT_ICON} %-7s${NC} | ${GREEN}${MSG_ICON} %-50s${NC}\n" \
	"$HOSTNAME" "$BUILD_DATE $BUILD_TIME" "$UPTIME" "#$COMMIT_COUNT" "$COMMIT_ID" "$COMMIT_MESSAGE"
