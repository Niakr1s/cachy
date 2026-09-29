#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log_info "Disabling power button..."

sudo mkdir -p /etc/systemd/logind.conf.d

sudo tee /etc/systemd/logind.conf.d/disable-power-button.conf > /dev/null << EOF
[Login]
HandlePowerKey=ignore
HandlePowerKeyLongPress=ignore
EOF
