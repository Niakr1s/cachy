#!/usr/bin/env bash
# Add the current user to all groups listed in GROUPS_TO_ADD.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

configure_amneziawg() {
  pkg_install amneziawg-tools amneziawg-dkms

  SRC="$HOME/sync/wg0.conf"
  DST="/etc/amnezia/amneziawg/wg0.conf"

  if [ ! -e "$SRC" ]; then
    echo "Error: $SRC does not exist. Generate it at https://warp-generation.github.io/ and rerun this." >&2
    exit 1
  fi

  log_info "Creating a symlink from $SRC to $DST"
  sudo ln -sf "$SRC" "$DST"

  sudo systemctl daemon-reload

  add_sudoers_systemctl "awg-quick@wg0.service"
}

configure_xray_knife() {
  sudo tee /etc/systemd/system/xray-knife.service >/dev/null <<'EOF'
[Unit]
Description=Xray Knife Proxy System
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/home/user/scripts/xray-knife-tun.sh
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload

  add_sudoers_systemctl "xray-knife.service"
}

configure_amneziawg
configure_xray_knife
