#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

APT_PKGS=(
)

AUR_PKGS=(
  vkbasalt
  lib32-vkbasalt
)

AM_PKGS=(
)

pkg_install "${APT_PKGS[@]}"
aur_install "${AUR_PKGS[@]}"
am_install "${AM_PKGS[@]}"
