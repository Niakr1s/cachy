#!/bin/sh
set -eu

USER_HOME="/home/user"
IFACE=$(ip -br link | awk '$1 ~ /^(eno|wlan)/ && $2 == "UP" {print $1; exit}')

if [ -z "${IFACE:-}" ]; then
    echo "No suitable interface found" >&2
    exit 1
fi

$USER_HOME/go/bin/xray-knife proxy tun --db $USER_HOME/.xray-knife/xray-knife.db --bind "$IFACE" --tun-deadman 0
