# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

#FIXME: sync without ssh
# Check if repo URL is provided
if [ "$#" -ne 1 ]; then
	echo -e "${RED}Error: Repository URL is required.${NC}"
	echo "Usage: $0 <repository_url>"
	exit 1
fi

REPO_URL=$1
CHEZMOI_DIR="$HOME/.local/share/chezmoi"

# Function to run chezmoi commands and capture output
run_chezmoi() {
	chezmoi "$@" 2>&1
}

# Initialize chezmoi if not already initialized
if [ ! -d "$CHEZMOI_DIR" ]; then
	echo -e "${BLUE}Initializing chezmoi from $REPO_URL${NC}"
	run_chezmoi init "$REPO_URL" >/dev/null
	if [ $? -ne 0 ]; then
		echo -e "${RED}Failed to initialize chezmoi.${NC}"
		exit 1
	fi
	echo -e "${GREEN}Chezmoi initialized successfully.${NC}"
fi

# Update chezmoi repository
echo -e "${BLUE}Updating Chezmoi repository...${NC}"
update_output=$(run_chezmoi update --force)
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to update Chezmoi:${NC}"
	echo "$update_output"
	exit 1
fi

# Check for changes
changes=$(echo "$update_output" | grep -E "^(A|M|R) ")
if [ ! -z "$changes" ]; then
	echo -e "${GREEN}Changes detected:${NC}"
	echo "$changes"
else
	echo -e "${GREEN}No changes detected.${NC}"
fi

# Apply changes
echo -e "${BLUE}Applying Chezmoi changes...${NC}"
apply_output=$(run_chezmoi apply --force)
if [ $? -ne 0 ]; then
	echo -e "${RED}Failed to apply changes:${NC}"
	echo "$apply_output"
	exit 1
fi

# Check final status
status_output=$(run_chezmoi status)
if [ ! -z "$status_output" ]; then
	echo -e "${YELLOW}Some files are not in sync:${NC}"
	echo "$status_output"
else
	echo -e "${GREEN}All files are in sync.${NC}"
fi

echo -e "${GREEN}Chezmoi update completed successfully.${NC}"
