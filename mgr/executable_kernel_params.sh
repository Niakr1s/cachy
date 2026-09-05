#!/usr/bin/env bash

. $(dirname "$0")/.helpers.sh

cat << EOF
To add kernel params to GRUB, do:
    Edit /etc/default/grub and append your kernel options between the quotes in the GRUB_CMDLINE_LINUX_DEFAULT line:

        GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"

    And then automatically re-generate the grub.cfg file with:

        # grub-mkconfig -o /boot/grub/grub.cfg

Useful params:
  clearcpuid=514 # for gaming
  split_lock_detect=off # for gaming

  usbcore.quirks="057e:2009:ik" # fixes my gamepad
EOF
