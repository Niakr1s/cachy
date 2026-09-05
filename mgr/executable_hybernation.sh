#!/usr/bin/env bash
. $(dirname "$0")/.helpers.sh

ACTION="$1"

TARGETS=(
  sleep.target
  suspend.target
  hibernate.target
  hybrid-sleep.target
)

case "$ACTION" in
  disable|off)
    log_info "Disabling sleep and hybernation..."
    sudo systemctl mask "${TARGETS[@]}"
    log_info "Disabled."
    ;;
  enable|on)
    log_info "Enabling sleep and hybernation..."
    sudo systemctl unmask "${TARGETS[@]}"
    log_info "Enabled."
    ;;
  *)
    log_error "Usage: '$0 off' | '$0 on'"
esac
