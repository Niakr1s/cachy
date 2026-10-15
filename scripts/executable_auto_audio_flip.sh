#!/usr/bin/env bash

# --- FUNCTION DEFINITIONS ---
# Helper function to cleanly terminate any active swapped audio loops
stop_loopback() {
  pkill -f "pw-loopback.*swapped_audio"
}

# Function to clean up the loopback before the entire script exits
cleanup() {
  echo "Stopping auto-audio-flip daemon. Cleaning up loopback audio..."
  stop_loopback
  exit 0
}
# ----------------------------

# Ensure a clean slate on script startup
stop_loopback

# Trap SIGINT (Ctrl+C), SIGTERM (systemd/kill stop), and EXIT signals
trap cleanup SIGINT SIGTERM EXIT

# Monitor the accelerometer via iio-sensor-proxy
monitor-sensor | while read -r line; do
  if echo "$line" | grep -q "orientation changed: bottom-up"; then
    # Laptop is UPSIDE DOWN: Only start if it's not already running
    if ! pkill -0 -f "pw-loopback.*swapped_audio" 2>/dev/null; then
      pw-loopback -m '[[FL FR] [FR FL]]' \
        --capture-props='media.class=Audio/Sink node.name=swapped_audio node.description="Swapped Audio" audio.position=[FL,FR]' \
        --playback-props='audio.position=[FR,FL] stream.dont-remix=true' &

      # Brief pause for PipeWire to map the node properties
      sleep 0.5

      # Extract the ID directly using your tested syntax
      ID="$(pw-cli info swapped_audio | grep -oE 'id: [0-9]+' | awk '{print $2}')"

      # Verify the ID is a valid number
      if [[ "$ID" =~ ^[0-9]+$ ]]; then
        wpctl set-default "$ID"
      else
        echo "Error: Failed to fetch a valid numeric PipeWire Node ID for 'swapped_audio'. Got: '$ID'" >&2
      fi
    fi

  elif echo "$line" | grep -q -E "orientation changed: normal|orientation changed: left-up|orientation changed: right-up"; then
    # Laptop returned to NORMAL: Cleanly terminate the loopback tool
    stop_loopback
  fi
done
