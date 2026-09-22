#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

pkg_install wtype ydotool
aur_install voxtype-bin

sudo usermod -aG input $USER
voxtype setup

systemctl --user enable --now ydotool.service
systemctl --user enable --now voxtype
