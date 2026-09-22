#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

which dms && {
    log_info "DMS already installed, skipping..."
    exit 0
}

curl -fsSL https://install.danklinux.com | sh
