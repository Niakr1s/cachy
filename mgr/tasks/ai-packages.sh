#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

APT_PKGS=(
  opencode
)

AM_PKGS=(
  lmstudio
)

pkg_install "${APT_PKGS[@]}"
am_install "${AM_PKGS[@]}"
