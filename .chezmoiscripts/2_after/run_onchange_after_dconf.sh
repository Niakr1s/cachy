#!/usr/bin/env python3
"""
apply-dconf.py - Apply dconf settings from embedded config
Single file version - no external config file needed
"""

import subprocess
import sys

# ============================================================
# EMBEDDED CONFIGURATION - Edit this section as needed
# ============================================================
CONFIG = """
[org/gnome/TextEditor]
custom-font='Iosevka Nerd Font Mono 11'
highlight-current-line=true
restore-session=false
show-line-numbers=true
spellcheck=false
tab-width=uint32 4
use-system-font=false
style-scheme='Adwaita-dark'

[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='adw-gtk3-dark'
icon-theme='Adwaita'

[org/gnome/nautilus/list-view]
default-column-order=['name', 'size', 'type', 'owner', 'group', 'permissions', 'date_modified', 'date_accessed', 'date_created', 'recency', 'detailed_type']
default-visible-columns=['name', 'size', 'date_modified']
use-tree-view=true

[org/gnome/nautilus/preferences]
date-time-format='detailed'
default-folder-viewer='list-view'
show-create-link=true
show-delete-permanently=true

[org/gtk/gtk4/settings/file-chooser]
date-format='with-time'
show-hidden=true
sort-directories-first=true

[org/gtk/settings/file-chooser]
date-format='with-time'
location-mode='path-bar'
show-hidden=true
show-size-column=true
show-type-column=true
sidebar-width=175
sort-column='name'
sort-directories-first=true
sort-order='ascending'
type-format='category'
"""
# ============================================================

def parse_dconf_config(config_text):
    """Parse dconf config text and return list of (key, value) pairs"""
    settings = []
    current_schema = None

    for line in config_text.strip().split("\n"):
        line = line.strip()

        # Skip empty lines
        if not line:
            continue

        # Check for schema header like [org/gnome/desktop]
        if line.startswith("[") and line.endswith("]"):
            current_schema = line[1:-1]
            continue

        # Parse key=value pairs
        if "=" in line and current_schema:
            # Split on first '=' only
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip()

            # Build full dconf path
            full_path = f"/{current_schema}/{key}".replace("//", "/")
            settings.append((full_path, value))

    return settings


def apply_setting(key, value, dry_run=False):
    """Apply a single dconf setting using dconf write"""
    if dry_run:
        print(f"DRY RUN: Would apply {key} = {value}")
        return True

    try:
        # dconf write expects the value as-is (with quotes for strings)
        cmd = ["dconf", "write", key, value]
        result = subprocess.run(cmd, capture_output=True, text=True)

        if result.returncode == 0:
            print(f"✓ {key} = {value}")
            return True
        else:
            print(f"✗ {key} = {value}")
            print(f"  Error: {result.stderr.strip()}")
            return False
    except FileNotFoundError:
        print(f"✗ {key} = {value}")
        print("  Error: dconf command not found. Is dconf installed?")
        return False
    except Exception as e:
        print(f"✗ {key} = {value}")
        print(f"  Exception: {e}")
        return False


def main():
    # Parse command line arguments
    dry_run = False
    if len(sys.argv) > 1:
        if sys.argv[1] in ["-h", "--help"]:
            print("Usage: ./apply-dconf.py [--dry-run]")
            print("  --dry-run  Preview changes without applying them")
            sys.exit(0)
        elif sys.argv[1] == "--dry-run":
            dry_run = True

    # Parse the embedded config
    settings = parse_dconf_config(CONFIG)

    if not settings:
        print("No settings found in embedded config")
        sys.exit(1)

    print(f"Found {len(settings)} settings to apply")
    if dry_run:
        print("DRY RUN MODE - No changes will be made\n")
    else:
        print("\n")

    success = 0
    failed = 0

    for key, value in settings:
        if apply_setting(key, value, dry_run):
            success += 1
        else:
            failed += 1

    print("\n--- Summary ---")
    print(f"Success: {success}")
    print(f"Failed:  {failed}")

    if dry_run:
        print("\nRemove --dry-run to apply these changes")


if __name__ == "__main__":
    main()
