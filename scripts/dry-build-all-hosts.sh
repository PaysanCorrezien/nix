#!/usr/bin/env bash
set -euo pipefail

################################################################################
# Dry-build all NixOS host configurations to verify they evaluate
#
# Usage:
#   dry-build-all-hosts.sh              - Dry-build all hosts sequentially
#   dry-build-all-hosts.sh <host...>    - Dry-build specific hosts
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PATH="${SCRIPT_DIR}/.."
RESULTS_FILE="/tmp/nix-dry-build-results-$$.txt"

get_hosts() {
    nix flake show "$FLAKE_PATH" --json 2>/dev/null | \
        jq -r '.nixosConfigurations | keys[]' 2>/dev/null || \
        ls "$FLAKE_PATH/hosts/"*.nix 2>/dev/null | xargs -n1 basename | sed 's/\.nix$//'
}

dry_build_host() {
    local host="$1"
    local start_time end_time duration
    start_time=$(date +%s)

    echo -e "${BLUE}Dry-building${NC} $host..."

    local output
    if output=$(nixos-rebuild dry-build --flake "$FLAKE_PATH#$host" --accept-flake-config 2>&1); then
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

main() {
    cd "$FLAKE_PATH"

    local hosts=()
    if [[ $# -gt 0 ]]; then
        hosts=("$@")
    else
        mapfile -t hosts < <(get_hosts)
    fi

    if [[ ${#hosts[@]} -eq 0 ]]; then
        echo -e "${RED}No hosts found${NC}"
        exit 1
    fi

    > "$RESULTS_FILE"

    local failed=0
    for host in "${hosts[@]}"; do
        if ! dry_build_host "$host"; then
            ((failed++)) || true
        fi
        echo ""
    done

    echo "Results:"
    sort "$RESULTS_FILE" | while read -r line; do
        if [[ "$line" == OK* ]]; then
            echo -e "  ${GREEN}$line${NC}"
        else
            echo -e "  ${RED}$line${NC}"
        fi
    done

    if [[ $failed -gt 0 ]]; then
        echo -e "${RED}$failed host(s) failed to dry-build${NC}"
        exit 1
    fi
    echo -e "${GREEN}All hosts dry-built successfully${NC}"
}

trap 'rm -f "$RESULTS_FILE"' EXIT
main "$@"
