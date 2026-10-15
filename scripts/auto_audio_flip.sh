#!/usr/bin/env bash

# Ensure a clean slate on script startup
pkill -f "pw-loopback.*swapped_audio"

# Monitor the accelerometer via iio-sensor-proxy
monitor-sensor | while read -r line; do
    if echo "$line" | grep -q "orientation changed: bottom-up"; then
        # Laptop is UPSIDE DOWN: Only start if it's not already running
        if ! pkill -0 -f "pw-loopback.*swapped_audio" 2>/dev/null; then
            pw-loopback -m '[[FL FR] [FR FL]]' \
              --capture-props='media.class=Audio/Sink node.name=swapped_audio node.description="Swapped Audio" audio.position=[FL,FR]' \
              --playback-props='audio.position=[FR,FL] stream.dont-remix=true' &
        fi

    elif echo "$line" | grep -q -E "orientation changed: normal|orientation changed: left-up|orientation changed: right-up"; then
        # Laptop returned to NORMAL (or sides): Terminate the swap tool
        pkill -f "pw-loopback.*swapped_audio"
    fi
done
