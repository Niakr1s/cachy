#!/bin/bash
# .helpers.sh – shared utilities for mgr scripts

# Colors for logging
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

# Check if a command exists
command_exists() {
    command -v "$1" &>/dev/null
}

# Install one or more APT packages
apt_install() {
    local pkgs=($@)
    log_info "Installing: ${pkgs[*]}"
    sudo pacman -S --needed --noconfirm "${pkgs[@]}"
}

# Install one or more AUR packages
aur_install() {
    local pkgs=($@)
    log_info "Installing: ${pkgs[*]}"
    paru -S --needed --noconfirm "${pkgs[@]}"
}

# Install a Go package via go install
go_install() {
    command_exists go || {
        apt_install go
    }

    local pkgs=($@)
    for pkg in "${pkgs[@]}"; do
        log_info "Installing Go package: $pkg"
        go install "$pkg"
    done
}

# Install a Cargo package
cargo_install() {
    command_exists cargo || {
        apt_install cargo
    }

    local pkgs=($@)
    for pkg in "${pkgs[@]}"; do
        log_info "Installing Cargo package: $pkg"
        cargo install "$pkg"
    done
}

# Install a AM package
am_install() {
    command_exists am || {
        curl -sSf https://raw.githubusercontent.com/ivan-hc/AM/main/AM-INSTALLER | sh -s -- -i am
    }

    local pkgs=($@)
    for pkg in "${pkgs[@]}"; do
        if command_exists "$pkg"; then
            log_info "Skipping AM package (exists): $pkg"
        else
            log_info "Installing AM package: $pkg"
            am -i "$pkg"
        fi
    done
}
