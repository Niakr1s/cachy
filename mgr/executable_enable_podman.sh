#!/usr/bin/env bash

. $(dirname "$0")/.helpers.sh

# This will install the needed packages (note the "Windows 11" note below):
apt_install podman podman-docker podman-compose podman-desktop

sudo mkdir -p /etc/containers/registries.conf.d
echo 'unqualified-search-registries = ["docker.io"]' | sudo tee /etc/containers/registries.conf.d/10-unqualified-search-registries.conf > /dev/null
