#!/usr/bin/env bash
# Add the current user to all groups listed in GROUPS_TO_ADD.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

GROUPS_TO_ADD=(
    sys
    network
    libvirt
    greeter
    nopasswdlogin
    rfkill
    users
    video
    storage
    lp
    input
    audio
    wheel
)

# Make sure we're not running as root (sanity check)
if [[ "$(id -u)" -eq 0 ]]; then
    log_warn "Running as root. \$USER is 'root'."
fi

# Verify the script isn't run with sudo directly (which would make $USER=root)
if [[ -n "${SUDO_USER:-}" ]]; then
    log_warn "Invoked via sudo. Using SUDO_USER='$SUDO_USER' instead of '$USER'."
    TARGET_USER="$SUDO_USER"
else
    TARGET_USER="$USER"
fi

for group in "${GROUPS_TO_ADD[@]}"; do
    if getent group "$group" > /dev/null 2>&1; then
        log_info "Adding $TARGET_USER to group: $group"
        sudo usermod -aG "$group" "$TARGET_USER"
    else
        log_warn "Skipping '$group': group does not exist on this system."
    fi
done

log_info "Done. Log out and back in (or run 'newgrp <group>') for changes to take effect."
