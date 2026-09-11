#!/usr/bin/env bash
# add_user_to_groups.sh
# Adds the current user ($USER) to all groups listed in the GROUPS array.

# Define the groups you want to add the user to
GROUPS_TO_ADD=(
  input
)

# Make sure we're not running as root (optional sanity check)
if [[ "$(id -u)" -eq 0 ]]; then
  echo "Warning: running as root. \$USER is 'root'." >&2
fi

# Verify the script isn't run with sudo directly (which would make $USER=root)
if [[ -n "${SUDO_USER:-}" ]]; then
  echo "Warning: you invoked this via sudo. Using SUDO_USER='$SUDO_USER' instead of '$USER'."
  TARGET_USER="$SUDO_USER"
else
  TARGET_USER="$USER"
fi

for group in "${GROUPS_TO_ADD[@]}"; do
  if getent group "$group" > /dev/null 2>&1; then
    echo "Adding $TARGET_USER to group: $group"
    sudo usermod -aG "$group" "$TARGET_USER"
  else
    echo "Skipping '$group': group does not exist on this system." >&2
  fi
done

echo "Done. Log out and back in (or run 'newgrp <group>') for changes to take effect."
