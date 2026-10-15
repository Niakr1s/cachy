#!/usr/bin/env bash

# Monitor the accelerometer via iio-sensor-proxy
monitor-sensor | while read -r line; do
  if echo "$line" | grep -q "orientation changed: bottom-up"; then
    # Laptop is UPSIDE DOWN: Only start if it's not already running
    if ! pkill -0 -f "pw-loopback.*swapped_audio" 2>/dev/null; then
      pw-loopback -m '[[FL FR] [FR FL]]' \
        --capture-props='media.class=Audio/Sink node.name=swapped_audio node.description="Swapped Audio" audio.position=[FL,FR]' \
        --playback-props='audio.position=[FR,FL] stream.dont-remix=true' &

      # Brief pause for PipeWire to map the new virtual sink
      sleep 1

      # Force target routing using the named node directly
      wpctl set-default swapped_audio 2>/dev/null
    fi

  elif echo "$line" | grep -q -E "orientation changed: normal|orientation changed: left-up|orientation changed: right-up"; then
    pkill -f "pw-loopback.*swapped_audio"
  fi
done
