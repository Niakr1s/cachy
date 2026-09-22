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

echo "$USER ALL=(ALL) NOPASSWD: /bin/systemctl start awg-quick@wg0.service, /bin/systemctl stop awg-quick@wg0.service, /bin/systemctl status awg-quick@wg0.service, /bin/systemctl is-active awg-quick@wg0.service" | sudo tee /etc/sudoers.d/amneziawg > /dev/null && sudo chmod 0440 /etc/sudoers.d/amneziawg
