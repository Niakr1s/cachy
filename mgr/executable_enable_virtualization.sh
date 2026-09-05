#!/usr/bin/env bash

. $(dirname "$0")/.helpers.sh

# This will install the needed packages (note the "Windows 11" note below):
apt_install qemu-full virt-manager swtpm
# Force libvirt to use iptables
echo 'firewall_backend = "iptables"' | sudo tee -a /etc/libvirt/network.conf
# This will add the user to the "libvirt" group so they can use it:
sudo usermod -aG libvirt $USER
# LXC backend (optional, for linux containers, enabling both backends does not conflict):
sudo systemctl enable --now libvirtd.service
# QEMU backend (for VMs):
sudo systemctl enable --now libvirtd.socket
# This will bring Internet up in a VM whenever one starts:
sudo virsh net-autostart default
# And to enable the entire VM network to have unfettered transit: (You should consider if you need more granular firewall rules based on your use case and security posture)
sudo ufw route allow from 192.168.122.0/24
