#!/usr/bin/env bash
# Add the current user to all groups listed in GROUPS_TO_ADD.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

pkg_install amneziawg-tools amneziawg-dkms

SRC="$HOME/sync/wg0.conf"
DST="/etc/amnezia/amneziawg/wg0.conf"

if [ ! -e "$SRC" ]; then
    echo "Error: $SRC does not exist. Generate it at https://warp-generation.github.io/ and rerun this." >&2
    exit 1
fi

log_info "Creating a symlink from $SRC to $DST"
sudo ln -sf "$SRC" "$DST"

log_info "Enabling the service..."
sudo systemctl enable --now awg-quick@wg0.service

