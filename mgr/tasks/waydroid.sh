#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

log_info "Installing waydroid..."
pkg_install waydroid waydroid-image

log_info "Initializing waydroid..."
sudo waydroid init

log_info "Enabling waydroid service..."
sudo systemctl enable --now waydroid-container.service

log_info "Installing waydroid-script..."
aur_install waydroid-script-git

log_info "Installing arm translation layer..."
sudo waydroid-extras install libhoudini
