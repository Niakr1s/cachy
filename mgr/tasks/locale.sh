#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

MAIN_LOCALE="en_US.UTF-8"
TIME_LOCALE="en_DK.UTF-8"

LOCALE_CONF_STR="LANG=$MAIN_LOCALE
LC_TIME=$TIME_LOCALE"

LOCALE_CONF_PATH="/etc/locale.conf"
LOCALE_GEN_PATH="/etc/locale.gen"

log_info "Setting $LOCALE_CONF_PATH ..."

echo "$LOCALE_CONF_STR" | sudo tee "$LOCALE_CONF_PATH"

log_info "$LOCALE_CONF_PATH set."

log_info "Enabling $TIME_LOCALE in $LOCALE_GEN_PATH.."

for loc in "$MAIN_LOCALE" "$TIME_LOCALE"; do
  if grep -q "^$loc" "$LOCALE_GEN_PATH"; then
    log_info "$loc is already enabled, skipping..."
  else
    sudo sed -i "s/^#$loc/$loc/g" "$LOCALE_GEN_PATH"
    log_info "$loc enabled"
  fi
done

log_info "Running 'locale-gen'"

if ! sudo locale-gen ; then
  log_error "Command 'locale-gen' failed"
fi
