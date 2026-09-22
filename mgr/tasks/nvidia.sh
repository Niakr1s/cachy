#!/usr/bin/env bash
# NVIDIA setup (desktop only — the laptop has an Intel GPU):
#   - nvidia-container-toolkit, nvidia-prime packages
#   - nvidia-pstated daemon to manage GPU performance states

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/helpers.sh"

pkg_install nvidia-container-toolkit nvidia-prime

install_nvidia_pstated() {
  local url="https://github.com/sasha0552/nvidia-pstated/releases/download/v1.0.9/nvidia-pstated"
  local dest="/usr/local/bin/nvidia-pstated"
  local service_file="/etc/systemd/system/nvidia-pstated.service"

  log_info "Downloading nvidia-pstated..."
  sudo curl -L "$url" -o "$dest"

  log_info "Setting executable permissions..."
  sudo chmod +x "$dest"

  log_info "Creating systemd service file..."
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

  log_info "Reloading systemd manager configuration..."
  sudo systemctl daemon-reload

  log_info "Enabling nvidia-pstated service to start on boot..."
  sudo systemctl enable nvidia-pstated.service

  log_info "Starting nvidia-pstated service now..."
  sudo systemctl start nvidia-pstated.service

  log_info "Installation complete! Checking service status..."
  sudo systemctl status nvidia-pstated.service
}

install_nvidia_pstated
