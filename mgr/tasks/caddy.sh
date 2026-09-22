#!/usr/bin/env bash
# Add the current user to all groups listed in GROUPS_TO_ADD.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log_info "Adding caddy local proxies..."
"$SCRIPT_DIR/../tools/caddy-proxy" add syncthing.localhost 8384
"$SCRIPT_DIR/../tools/caddy-proxy" add comfyui.localhost 8188
"$SCRIPT_DIR/../tools/caddy-proxy" add windows.localhost 8006
