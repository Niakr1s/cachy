#!/usr/bin/env bash

. $(dirname "$0")/.helpers.sh

APT_PKGS=(
  opencode
)

AM_PKGS=(
  lmstudio
)

apt_install "${APT_PKGS[@]}"
am_install "${AM_PKGS[@]}"
