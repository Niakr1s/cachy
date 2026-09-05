#!/usr/bin/env bash
# Focuses left monitor

sleep 3
niri msg action focus-monitor-right
niri msg action focus-monitor-left

echo "Focused left monitor"
exit 0
