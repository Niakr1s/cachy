#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

APT_PKGS=(
    emacs
)

AM_PKGS=(
)

pkg_install "${APT_PKGS[@]}"
am_install "${AM_PKGS[@]}"

log_info "Cloning doom..."
git clone --depth 1 https://github.com/doomemacs/core ~/.config/emacs

log_info "Installing doom emacs..."
~/.config/emacs/bin/doom install
