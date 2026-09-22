#!/usr/bin/env bash
# Enable/disable sleep & hibernation targets: $0 on|off
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

ACTION="$1"

TARGETS=(
  sleep.target
  suspend.target
  hibernate.target
  hybrid-sleep.target
)

case "$ACTION" in
  disable|off)
    log_info "Disabling sleep and hibernation..."
    sudo systemctl mask "${TARGETS[@]}"
    log_info "Disabled."
    ;;
  enable|on)
    log_info "Enabling sleep and hibernation..."
    sudo systemctl unmask "${TARGETS[@]}"
    log_info "Enabled."
    ;;
  *)
    log_error "Usage: '$0 off' | '$0 on'"
esac
