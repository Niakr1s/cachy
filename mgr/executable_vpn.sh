#!/usr/bin/env bash

. $(dirname "$0")/.helpers.sh

apt_install amneziawg-tools amneziawg-dkms

SRC="$HOME/wg0.conf"
DST="/etc/amnezia/amneziawg/wg0.conf"

if [ ! -e "$SRC" ]; then
    echo "Error: $SRC does not exist. Generate it at https://warp-generation.github.io/ and rerun this." >&2
    exit 1
fi

log_info "Creating a symlink from $SRC to $DST"
sudo ln -sf "$SRC" "$DST"

log_info "Enabling the service..."
sudo systemctl enable --now awg-quick@wg0.service
