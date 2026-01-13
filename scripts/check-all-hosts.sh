#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Build all NixOS host configurations to verify they compile
#
# Usage:
#   check-all-hosts.sh              - Build all hosts sequentially
#   check-all-hosts.sh --parallel   - Build all hosts in parallel (faster, more RAM)
#   check-all-hosts.sh --quick      - Just run nix flake check (fastest)
#   check-all-hosts.sh <host>       - Build specific host only
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PATH="${SCRIPT_DIR}/.."
RESULTS_FILE="/tmp/nix-check-results-$$.txt"
PARALLEL_MODE=false
QUICK_MODE=false
SPECIFIC_HOST=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --parallel|-p)
            PARALLEL_MODE=true
            shift
            ;;
        --quick|-q)
            QUICK_MODE=true
            shift
            ;;
        --help|-h)
            cat <<EOF
Build All Hosts - NixOS Configuration Validator

Usage: check-all-hosts.sh [OPTIONS] [HOST]

Options:
  --parallel, -p    Build hosts in parallel (faster, uses more RAM)
  --quick, -q       Just run 'nix flake check' (fastest, less thorough)
  --help, -h        Show this help message

Arguments:
  HOST              Build only this specific host (optional)

Examples:
  check-all-hosts.sh              # Build all hosts sequentially
  check-all-hosts.sh --parallel   # Build all hosts in parallel
  check-all-hosts.sh --quick      # Quick flake check only
  check-all-hosts.sh wsl          # Build only the 'wsl' host
  check-all-hosts.sh lenovo workstation  # Build specific hosts

Exit codes:
  0 - All hosts built successfully
  1 - One or more hosts failed to build
EOF
            exit 0
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
        *)
            SPECIFIC_HOST="$SPECIFIC_HOST $1"
            shift
            ;;
    esac
done

# Trim whitespace
SPECIFIC_HOST="${SPECIFIC_HOST## }"

# Get list of hosts from flake
get_hosts() {
    nix flake show "$FLAKE_PATH" --json 2>/dev/null | \
        jq -r '.nixosConfigurations | keys[]' 2>/dev/null || \
        ls "$FLAKE_PATH/hosts/"*.nix 2>/dev/null | xargs -n1 basename | sed 's/\.nix$//'
}

# Build a single host
build_host() {
    local host="$1"
    local start_time end_time duration
    start_time=$(date +%s)

    echo -e "${BLUE}Building${NC} $host..."

    local output
    if output=$(nix build "$FLAKE_PATH#nixosConfigurations.$host.config.system.build.toplevel" \
        --no-link \
        --accept-flake-config \
        --show-trace 2>&1); then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo -e "${GREEN}OK${NC} $host (${duration}s)"
        echo "OK $host ${duration}s" >> "$RESULTS_FILE"
        return 0
    else
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        echo -e "${RED}FAILED${NC} $host (${duration}s)"
        echo "$output" | tail -20
        echo "FAILED $host ${duration}s" >> "$RESULTS_FILE"
        return 1
    fi
}

# Quick flake check mode
run_quick_check() {
    echo -e "${BLUE}Running nix flake check...${NC}"
    echo ""

    if nix flake check "$FLAKE_PATH" --accept-flake-config --show-trace; then
        echo ""
        echo -e "${GREEN}Flake check passed${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}Flake check failed${NC}"
        return 1
    fi
}

# Main execution
main() {
    cd "$FLAKE_PATH"

    echo "========================================"
    echo "  NixOS Configuration Validator"
    echo "========================================"
    echo ""
    echo "Flake: $FLAKE_PATH"
    echo ""

    # Quick mode - just flake check
    if $QUICK_MODE; then
        run_quick_check
        exit $?
    fi

    # Get hosts to build
    local hosts
    if [[ -n "$SPECIFIC_HOST" ]]; then
        hosts=($SPECIFIC_HOST)
    else
        mapfile -t hosts < <(get_hosts)
    fi

    if [[ ${#hosts[@]} -eq 0 ]]; then
        echo -e "${RED}No hosts found${NC}"
        exit 1
    fi

    echo "Hosts to build: ${hosts[*]}"
    echo "Mode: $($PARALLEL_MODE && echo "parallel" || echo "sequential")"
    echo ""
    echo "----------------------------------------"

    # Initialize results file
    > "$RESULTS_FILE"

    local failed=0
    local start_total end_total
    start_total=$(date +%s)

    if $PARALLEL_MODE; then
        # Parallel builds
        local pids=()
        for host in "${hosts[@]}"; do
            build_host "$host" &
            pids+=($!)
        done

        # Wait for all and collect exit codes
        for pid in "${pids[@]}"; do
            if ! wait "$pid"; then
                ((failed++)) || true
            fi
        done
    else
        # Sequential builds
        for host in "${hosts[@]}"; do
            if ! build_host "$host"; then
                ((failed++)) || true
            fi
            echo ""
        done
    fi

    end_total=$(date +%s)
    local total_duration=$((end_total - start_total))

    # Summary
    echo "========================================"
    echo "  Results Summary"
    echo "========================================"
    echo ""

    local passed=$((${#hosts[@]} - failed))

    if [[ -f "$RESULTS_FILE" ]]; then
        # Show results sorted
        echo "Results:"
        sort "$RESULTS_FILE" | while read -r line; do
            if [[ "$line" == OK* ]]; then
                echo -e "  ${GREEN}$line${NC}"
            else
                echo -e "  ${RED}$line${NC}"
            fi
        done
        echo ""
    fi

    echo "Total: $passed/${#hosts[@]} passed in ${total_duration}s"
    echo ""

    if [[ $failed -gt 0 ]]; then
        echo -e "${RED}$failed host(s) failed to build${NC}"
        rm -f "$RESULTS_FILE"
        exit 1
    else
        echo -e "${GREEN}All hosts built successfully${NC}"
        rm -f "$RESULTS_FILE"
        exit 0
    fi
}

# Cleanup on exit
trap 'rm -f "$RESULTS_FILE"' EXIT

main "$@"
