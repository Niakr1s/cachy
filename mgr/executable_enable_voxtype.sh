#!/usr/bin/env bash

. $(dirname "$0")/.helpers.sh

apt_install wtype ydotool
aur_install voxtype-bin

sudo usermod -aG input $USER
voxtype setup

systemctl --user enable --now ydotool.service
systemctl --user enable --now voxtype
