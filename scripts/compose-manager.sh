#!/usr/bin/env bash

# User Configuration
HOME_DIR="$HOME"
ENV_FILE="$HOME_DIR/.env"
DOCKER_COMPOSE="docker compose" # Changed to new format
DEFAULT_LOG_LINES="100"         # Default number of lines for logs

# Colors for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Help message
show_help() {
	echo -e "${BLUE}Docker Compose Manager${NC}"
	echo
	echo "Usage:"
	echo "  $0 [compose-files...] [COMMAND] [OPTIONS]"
	echo "  $0 startall          # Start all *-compose.yml files in home directory"
	echo
	echo "Commands:"
	echo "  up        Start containers (default if no command specified)"
	echo "  down      Stop containers"
	echo "  ps        Show container status"
	echo "  logs      Show container logs"
	echo "  restart   Restart containers"
	echo "  startall  Start all compose files in home directory"
	echo
	echo "Options:"
	echo "  -s, --service  Specific service(s) to target"
	echo "  -f, --follow   Follow log output (for logs command)"
	echo "  -t, --tail N   Show last N lines of logs (default: $DEFAULT_LOG_LINES)"
	echo "  -n, --names    Show container names in logs"
	echo "  -ts,--timestamps Show timestamps in logs"
	echo "  --no-color     Disable color in logs"
	echo "  -h, --help     Show this help message"
	echo
	echo "Log Examples:"
	echo "  $0 ia-compose.yml logs                    # Show last $DEFAULT_LOG_LINES lines"
	echo "  $0 ia-compose.yml logs -f                 # Follow logs"
	echo "  $0 ia-compose.yml logs -t 500            # Show last 500 lines"
	echo "  $0 ia-compose.yml logs -f -s myservice   # Follow specific service"
	echo "  $0 ia-compose.yml logs --timestamps      # Show timestamps"
	echo
	echo "General Examples:"
	echo "  $0 ia-compose.yml monitoring-compose.yml  # Start multiple files"
	echo "  $0 startall                              # Start all compose files"
	echo "  $0 ia-compose.yml restart                # Restart services"
}

# Load all compose files from home directory
load_all_compose_files() {
	echo -e "${YELLOW}Loading all *-compose.yml files from $HOME_DIR${NC}"
	COMPOSE_FILES=()
	for file in "$HOME_DIR"/*-compose.yml; do
		if [ -f "$file" ]; then
			COMPOSE_FILES+=("$file")
			echo -e "${GREEN}Found: $(basename "$file")${NC}"
		fi
	done

	if [ ${#COMPOSE_FILES[@]} -eq 0 ]; then
		echo -e "${RED}Error: No *-compose.yml files found in $HOME_DIR${NC}"
		exit 1
	fi
}

# Build docker-compose command
build_compose_command() {
	local cmd="$DOCKER_COMPOSE"
	local action="$1"

	# Add environment file
	if [ -f "$ENV_FILE" ]; then
		cmd="$cmd --env-file $ENV_FILE"
	else
		echo -e "${YELLOW}Warning: Env file $ENV_FILE not found${NC}"
	fi

	# Add compose files
	for file in "${COMPOSE_FILES[@]}"; do
		cmd="$cmd -f $file"
	done

	# Add action and services
	cmd="$cmd $action"
	if [ -n "$SERVICES" ]; then
		cmd="$cmd $SERVICES"
	fi

	# Add log options if this is a log command
	if [[ "$action" == "logs"* ]]; then
		if [ -n "$LOG_FOLLOW" ]; then
			cmd="$cmd --follow"
		fi
		if [ -n "$LOG_TAIL" ]; then
			cmd="$cmd --tail=$LOG_TAIL"
		else
			cmd="$cmd --tail=$DEFAULT_LOG_LINES"
		fi
		if [ -n "$LOG_TIMESTAMPS" ]; then
			cmd="$cmd --timestamps"
		fi
		if [ -n "$LOG_NO_COLOR" ]; then
			cmd="$cmd --no-color"
		fi
		if [ -n "$LOG_NAMES" ]; then
			cmd="$cmd --service-names"
		fi
	fi

	echo "$cmd"
}

# Execute restart for each service in compose files
do_restart() {
	echo -e "${YELLOW}Stopping services...${NC}"
	local stop_cmd=$(build_compose_command "stop")
	eval "$stop_cmd"

	echo -e "${YELLOW}Starting services...${NC}"
	local start_cmd=$(build_compose_command "up -d")
	eval "$start_cmd"

	echo -e "${GREEN}Restart completed${NC}"
}

# Show services in compose files
show_services() {
	echo -e "${BLUE}Available services in selected compose files:${NC}"
	for file in "${COMPOSE_FILES[@]}"; do
		echo -e "${YELLOW}In $(basename "$file"):${NC}"
		$DOCKER_COMPOSE -f "$file" config --services
	done
}

# Parse command line arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
	case $1 in
	-s | --service)
		shift
		SERVICES="$1"
		;;
	-f | --follow)
		LOG_FOLLOW=1
		;;
	-t | --tail)
		shift
		LOG_TAIL="$1"
		;;
	--timestamps | -ts)
		LOG_TIMESTAMPS=1
		;;
	--no-color)
		LOG_NO_COLOR=1
		;;
	-n | --names)
		LOG_NAMES=1
		;;
	-h | --help)
		show_help
		exit 0
		;;
	--list-services)
		SHOW_SERVICES=1
		;;
	startall)
		ACTION="up -d"
		load_all_compose_files
		break
		;;
	up | down | ps | restart)
		ACTION="$1"
		;;
	logs)
		ACTION="logs"
		;;
	*)
		# Check if it's a compose file
		if [[ $1 == *-compose.yml ]]; then
			if [ -f "$HOME_DIR/$(basename "$1")" ]; then
				COMPOSE_FILES+=("$HOME_DIR/$(basename "$1")")
			else
				echo -e "${RED}Error: Compose file not found: $1${NC}"
				exit 1
			fi
		else
			POSITIONAL_ARGS+=("$1")
		fi
		;;
	esac
	shift
done

# If no compose files specified and not startall, use all compose files
if [ ${#COMPOSE_FILES[@]} -eq 0 ] && [ "$ACTION" != "startall" ]; then
	echo -e "${YELLOW}No compose files specified, using all available compose files${NC}"
	load_all_compose_files
fi

# If no action specified, default to "up -d"
if [ -z "$ACTION" ]; then
	ACTION="up -d"
fi

# Show services if requested
if [ -n "$SHOW_SERVICES" ]; then
	show_services
	exit 0
fi

# Execute command
echo -e "${YELLOW}Executing command for ${#COMPOSE_FILES[@]} compose files:${NC}"
for file in "${COMPOSE_FILES[@]}"; do
	echo -e "${BLUE}- $(basename "$file")${NC}"
done

if [ "$ACTION" = "restart" ]; then
	do_restart
else
	cmd=$(build_compose_command "$ACTION")
	echo -e "${GREEN}Running: $cmd${NC}"
	eval "$cmd"
fi
