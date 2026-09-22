#!/usr/bin/env bash

install_switch_emulators() {
    echo "Installing Ryujinx..."
    am -i ryujinx

    echo "Downloading and install keys..."
    mkdir -p "$HOME/.config/Ryujinx/system"
    wget -O- "https://archive.org/download/20.0.1-keys/20.0.1 Keys.zip" | bsdtar -xf- -C "$HOME/.config/Ryujinx/system"

    echo "Downloading and installing cheats..."
    mkdir -p $HOME/.config/Ryujinx/mods
    wget -O- "https://github.com/HamletDuFromage/switch-cheats-db/releases/download/2026-04-18/contents_complete.zip" | bsdtar -xf- -C "$HOME/.config/Ryujinx/mods"

    echo "1" | am -i eden # choose '1) AMD64 (PGO)' variant
    echo "Downloading and install keys..."
    mkdir -p "$HOME/.local/share/eden/keys"
    wget -O- "https://archive.org/download/20.0.1-keys/20.0.1 Keys.zip" | bsdtar -xf- -C "$HOME/.local/share/eden/keys"

    cat << EOF
Eden configuration:
  - VULKAN BALANCED DOCKED SCALEFORCE SMAA
EOF

    local SWITCH_FIRMWARE_PATH="$HOME/.cache/SwitchFirmware.zip"
    if [[ ! -e "$SWITCH_FIRMWARE_PATH" ]]; then
        echo "Downloading firmware to ~/.cache..."
        wget -O "$SWITCH_FIRMWARE_PATH" "https://github.com/THZoria/NX_Firmware/releases/download/20.0.1/Firmware.20.0.1.zip"
    fi
    echo "Switch firmware is at $SWITCH_FIRMWARE_PATH, don't forget to install it"
}

install_playstation_emulators() {
    echo "Installing pcsx2"
    am -i pcsx2

    echo "Installing bioses..."
    mkdir -p "$HOME/.config/PCSX2/bios"
    for region in a e j h; do wget -O- "https://github.com/archtaurus/RetroPieBIOS/raw/refs/heads/master/BIOS/pcsx2/bios/ps2-0230${region}-20080220.bin" > "$HOME/.config/PCSX2/bios/ps2-0230${region}-20080220.bin"; done

    echo "Installing rpcs3"
    am -i rpcs3

    local PCS3_FIRMWARE_PATH="$HOME/.cache/PS3UPDAT.PUP"
    echo "Downloading PS3 firmware to $PCS3_FIRMWARE_PATH"
    wget -P "$PCS3_FIRMWARE_PATH" "http://dus01.ps3.update.playstation.net/update/ps3/image/us/2026_0318_a2b60b6ac1d2e49e230144345616927c/PS3UPDAT.PUP"
    echo "PS3 firmware is at $PCS3_FIRMWARE_PATH, don't forget to install it"

    echo "Installing ps3dec (tool for decrypting ps3 iso)..."
    cargo install --git https://github.com/Redrrx/ps3dec

    echo "Installing shadPS4..."
    am -i shadps4-qtlauncher

    echo "Installing azaharplus-pkg-extractor for shadPS4..."

    # appimage-download "shadPS4-PKGInstall" "https://github.com/Muggle345/PKGInstall/releases/download/Release/PKGInstall-linux-AppImage-2025-10-24-96c7890.zip"
    am -i azaharplus-pkg-extractor
}

install_xbox_emulators() {
    echo "Installing xemu..."
    am -i xemu
    mkdir -p "$HOME/.local/share/xemu"
    wget -O- "https://archive.org/download/xemustarter/XEMU FILES.zip" | bsdtar -xf- -C "$HOME/.local/share/xemu"
    echo "Needed xemu fiiles are under $HOME/.local/share/xemu, provide it to emulator them manually"
}

install_retroarch() {
    echo "Installing retroarch..."
    echo "Refer to docs/retroarch.md for further configuration"
    am -i retroarch

    echo "Removing portable home for retroarch to use usual directories.."
    sudo rm -rf /opt/retroarch/retroarch.home
    mkdir -p ~/.config/retroarch
}

install_switch_emulators
install_playstation_emulators
install_xbox_emulators
install_retroarch
