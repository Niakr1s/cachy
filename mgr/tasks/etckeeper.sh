#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

APT_PKGS=(
  etckeeper
)

AM_PKGS=(
)

pkg_install "${APT_PKGS[@]}"
am_install "${AM_PKGS[@]}"

log_info "Creating symlink for .gitconfig..."
sudo ln -s ~/.gitconfig /root/.gitconfig

GIT_DIR="/etc/.git"
log_info "Initializing and making initial config..."
if [[ -d "$GIT_DIR" ]]; then
  sudo etckeeper init
  sudo etckeeper commit "initial"
else
  log_info "$GIT_DIR exists, skipping initalizing."
fi

log_info "Enabling daily commit..."
sudo systemctl enable --now etckeeper.timer
