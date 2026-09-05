#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

install_nvidia_pstated() {
  local url="https://github.com/sasha0552/nvidia-pstated/releases/download/v1.0.9/nvidia-pstated"
  local dest="/usr/local/bin/nvidia-pstated"
  local service_file="/etc/systemd/system/nvidia-pstated.service"

  echo "Downloading nvidia-pstated..."
  sudo curl -L "$url" -o "$dest"

  echo "Setting executable permissions..."
  sudo chmod +x "$dest"

  echo "Creating systemd service file..."
  sudo tee "$service_file" > /dev/null << 'EOF'
[Unit]
Description=A daemon that automatically manages the performance states of NVIDIA GPUs
After=nvidia-persistenced.service
BindsTo=nvidia-persistenced.service

[Service]
DynamicUser=yes
ExecStart=/usr/local/bin/nvidia-pstated
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target
EOF

  echo "Reloading systemd manager configuration..."
  sudo systemctl daemon-reload

  echo "Enabling nvidia-pstated service to start on boot..."
  sudo systemctl enable nvidia-pstated.service

  echo "Starting nvidia-pstated service now..."
  sudo systemctl start nvidia-pstated.service

  echo "Installation complete! Checking service status..."
  sudo systemctl status nvidia-pstated.service
}

# Execute the function
install_nvidia_pstated

