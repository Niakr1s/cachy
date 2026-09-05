#!/usr/bin/env bash
# Waits for the system tray D-Bus service

echo "Waiting for system tray (StatusNotifierWatcher)..."

for i in {1..30}; do
    if dbus-send --session --dest=org.freedesktop.DBus \
        --type=method_call --print-reply \
        /org/freedesktop/DBus \
        org.freedesktop.DBus.NameHasOwner \
        string:org.kde.StatusNotifierWatcher 2>/dev/null | grep -q "boolean true"; then
        echo "System tray found!"
        exit 0
    fi
    echo -n "."
    sleep 1
done

echo "Timeout: System tray not found, continuing anyway"
exit 0
