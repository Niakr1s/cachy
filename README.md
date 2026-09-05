# Post install

## Kernel params

To add kernel params to GRUB, do:
Edit /etc/default/grub and append your kernel options between the quotes in the GRUB_CMDLINE_LINUX_DEFAULT line:

```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

And then automatically re-generate the grub.cfg file with:

```
# grub-mkconfig -o /boot/grub/grub.cfg
```

Useful params:

- clearcpuid=514 # for gaming
- split_lock_detect=off # for gaming
- usbcore.quirks="057e:2009:ik" # fixes my gamepad

## Enabling TRIM on Encrypted (LUKS) Devices

1. Identify your active LUKS mapper name:

   ```
   lsblk
   ```

   Look for the `crypt` type entry under your disk partition (e.g., `luks-1e647929-62c0-4922-8944-f941ed4155fd`).

2. Enable persistent discard passthrough on the active LUKS mapping:

   ```
   sudo cryptsetup --allow-discards --persistent refresh <mapper_name>
   ```
3. Reboot your system to apply the changes.

4. Verify that discard passthrough is active:

   ```
   lsblk -D
   sudo fstrim -v /
   ```

   `lsblk -D` should now display non-zero values under `DISC-GRAN` and `DISC-MAX` for your encrypted volume, and `fstrim` will output the amount of trimmed space rather than skipping the device.
