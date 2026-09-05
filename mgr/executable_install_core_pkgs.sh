#!/usr/bin/env bash

. $(dirname "$0")/.helpers.sh

APT_PKGS=(
    paru
    wl-clipboard
    neovim python-pynvim
    glow
    nvtop
    yazi
    borgbackup python-pyfuse3
    zoxide
    chezmoi
    direnv
    eza
    fzf
    tree
    bottom
    duf
    gdu
    playerctl
    aria2
    xclip
    mediainfo
    ripgrep
    rofi
    tealdeer
    pkgfile
    vulkan-tools
    compsize
    lazygit
    mitmproxy
    jp2a
    imagemagick
    gpu-viewer
    gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly

    # archive
    unarchiver zip unzip unrar lz4 7zip

    # libs
    # needed for joystickwake
    python-pyudev
    python-dbus-fast
    python-xlib
    fuse2

    # fonts
    ttf-firacode-nerd
    ttf-inconsolata-lgc-nerd

    # services
    xdg-desktop-portal-gnome
    xdg-desktop-portal-wlr
    syncthing

    # programming
    cmake ninja
    go
    nodejs npm
    cargo lldb
    ruby tk ruby-stdlib

    # nvidia
    nvidia-container-toolkit
    nvidia-prime

    # theming
    qt6ct
    adw-gtk-theme

    # gui
    gimp inkscape
    libreoffice
    librecad
    mission-center
    gthumb
    firefox
    chromium
    qbittorrent
    nautilus
    sqlitebrowser
    foliate
    weechat
    gnome-text-editor
    gnome-disk-utility
    keepassxc
    dconf-editor
    remmina
    kitty
    handbrake
    strawberry
    kdeconnect
    kid3
    zed
    strawberry
    mpv
    telegram-desktop
    moonlight-qt
    obsidian
    sunshine

    # hardware
    cpu-x vulkan-driver
    hardinfo2 apcupsd fwupd
    occt

    # games
    goverlay mangohud gamescope gamemode
)

AUR_PKGS=(
    lisgd
    throne-bin
)

GO_PKGS=(
    github.com/jorgerojas26/lazysql@latest
    github.com/asdf-vm/asdf/cmd/asdf@v0.20.0
)

CARGO_PKGS=(
    ripdrag
)

AM_PKGS=(
    losslesscut
    nomacs
)

apt_install "${APT_PKGS[@]}"
aur_install "${AUR_PKGS[@]}"
go_install "${GO_PKGS[@]}"
cargo_install "${CARGO_PKGS[@]}"
am_install "${AM_PKGS[@]}"

sudo pkgfile --update # don't know where to put it, but don't want to forget
