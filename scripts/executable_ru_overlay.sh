#!/usr/bin/env python3

import glob
import json
import os
import socket
import sys
import threading
import time
import warnings
from ctypes import CDLL
import gi

warnings.filterwarnings("ignore", category=DeprecationWarning)

try:
    CDLL('libgtk4-layer-shell.so')
except OSError:
    print("Error: Please install the library: yay -S gtk4-layer-shell", file=sys.stderr)
    sys.exit(1)

gi.require_version('Gtk', '4.0')
gi.require_version('Gdk', '4.0')
gi.require_version('Gtk4LayerShell', '1.0')

from gi.repository import Gtk, Gdk, GLib, Gtk4LayerShell as LayerShell
import cairo

class TrueWaylandOverlay:
    def __init__(self):
        self.app = Gtk.Application(application_id="ru-layout-overlay")
        self.app.connect('activate', self.on_activate)
        # Overlay windows keyed by Gdk monitor identity. Keeping them in a dict
        # lets us react to monitors being connected/disconnected after startup
        # (e.g. a second screen plugged in later) without restarting the app.
        self.id_to_win = {}
        self.ru_active = False
        # Caps-Lock indicator state, driven by the sysfs poller below.
        self.caps_lock = False
        self.running = True

    def apply_transparent_theme(self):
        """Injects a CSS provider to strip out standard GTK window backgrounds."""
        css_provider = Gtk.CssProvider()
        # Forces the window background color to be completely transparent alpha
        css_provider.load_from_data(b"window { background-color: transparent; }")
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

    def create_indicator_window(self, app, monitor):
        win = Gtk.ApplicationWindow(application=app)
        win.set_title("RU Layout Indicator")

        LayerShell.init_for_window(win)
        LayerShell.set_monitor(win, monitor)
        LayerShell.set_layer(win, LayerShell.Layer.OVERLAY)
        LayerShell.set_keyboard_mode(win, LayerShell.KeyboardMode.NONE)

        # Position: Center Bottom alignment
        LayerShell.set_anchor(win, LayerShell.Edge.BOTTOM, True)
        LayerShell.set_margin(win, LayerShell.Edge.BOTTOM, 60)

        win.set_decorated(False)
        win.set_focusable(False)
        win.set_default_size(80, 50)

        win.connect("realize", self.make_click_through)

        label = Gtk.Label()
        label.set_halign(Gtk.Align.CENTER)
        # Renders the current indicator: an optional ⇪ (Caps Lock) immediately
        # to the left of "RU" when the Russian layout is active. The window stays
        # visible on every monitor, so Caps Lock is shown regardless of layout.
        label.set_markup(self._indicator_markup())
        win.set_child(label)

        win.present()

        return win

    def on_activate(self, app):
        # Apply transparency rules globally to the application's render loop
        self.apply_transparent_theme()

        # Create one overlay window per currently visible monitor right away.
        self._reconcile_monitors()

        # React to monitors being connected/disconnected at runtime (e.g. a second
        # screen plugged in after startup) by re-checking periodically.
        threading.Thread(target=self._poll_monitors, daemon=True).start()

        # Watch for keyboard layout switches so "RU" appears when Russian is active.
        threading.Thread(target=self.listen_to_niri, daemon=True).start()

        # Initialise Caps Lock from sysfs so the indicator reflects reality
        # immediately, even if caps was already latched before startup.
        self.caps_lock = self._current_caps_lock()

        # Track Caps Lock state via its LED brightness attribute in sysfs
        # (see _watch_caps_lock()). Niri mirrors the physical LED to match the
        # latched lock, so no event parsing is needed.
        threading.Thread(target=self._watch_caps_lock, daemon=True).start()

    # --- Caps Lock indicator (sysfs) ------------------------------------------
    _LED_PATTERNS = (
        "/sys/class/leds/*capslock*/brightness",
        "/sys/class/leds/*caps*/brightness",
        "/sys/class/input/input*/capslock/brightness",
    )

    def _current_caps_lock(self):
        """Return True/False for current Caps Lock state, or None if unsupported.

        Niri drives the keyboard's LED to mirror the latched Caps Lock state; we
        read that sysfs brightness file directly, so detection needs no event
        parsing and correctly reports caps even when it was already on at launch.
        """
        for pattern in self._LED_PATTERNS:
            matches = glob.glob(pattern)
            if not matches:
                continue
            try:
                with open(matches[0], "r") as f:
                    value = f.read().strip()
            except OSError:
                continue
            if value in ("0", "1"):
                return value == "1"
        # No readable LED attribute available on this system.
        return None

    def _watch_caps_lock(self):
        """Background thread: poll sysfs for Caps Lock and update the label.

        Polls periodically; any change flips self.caps_lock, refreshed on the GTK
        main thread via GLib.idle_add. Runs forever until self.running is cleared.
        Returns early (leaving the RU overlay fully working) if no LED attribute
        is readable on this system.
        """
        state = self._current_caps_lock()
        if state is None:
            print("ru_overlay: no Caps Lock sysfs support; indicator disabled",
                  file=sys.stderr)
            return
        self.caps_lock = state
        while self.running:
            try:
                new_state = self._current_caps_lock()
            except Exception as e:
                print(f"ru_overlay: caps lock poll error: {e}", file=sys.stderr)
                new_state = None
            if new_state is not None and new_state != self.caps_lock:
                self.caps_lock = new_state
                GLib.idle_add(self._refresh_all_labels)
            time.sleep(0.25)

    def _indicator_markup(self):
        """Compose the bottom indicator label from current state.

        Returns an optional ⇪ (Caps Lock) immediately to the left of "RU", e.g.:
          EN, caps off  -> ""   EN, caps on -> "⇪"
          RU, caps off  -> "RU"          RU, caps on -> "⇪ RU"

        Uses no leading/trailing spacing when a part is empty.
        """
        parts = []
        if self.caps_lock:
            parts.append('<span font="Bold 22" foreground="#DDDDDD">\u21e4</span>')
        if self.ru_active:
            parts.append('<span font="Bold 22" foreground="#FF5555">RU</span>')
        return ' '.join(parts)

    def _refresh_all_labels(self):
        """Re-render the indicator label on every overlay window.

        Runs on the GTK main thread (called directly from window creation or via
        GLib.idle_add when Caps Lock / layout state changes). Does not touch
        visibility, so it is safe to call even between monitor reconciliations.
        """
        for win in list(self.id_to_win.values()):
            child = win.get_child()
            if getattr(child, "set_markup", None) is not None:
                child.set_markup(self._indicator_markup())

    def _reconcile_monitors(self):
        """Make sure there is exactly one overlay window per visible Gdk monitor.

        Called once at startup and then periodically (via a background thread),
        so that monitors which are plugged in *after* startup - or removed - are
        picked up automatically without restarting the app. Runs on the GTK main
        thread.
        """
        display = Gdk.Display.get_default()
        if display is None:
            return

        try:
            current = list(display.get_monitors())
        except Exception as e:
            print(f"Failed to enumerate monitors: {e}", file=sys.stderr)
            return

        current_ids = {id(m) for m in current}

        # Add a window for every monitor that doesn't have one yet.
        for mon in current:
            if id(mon) not in self.id_to_win:
                try:
                    win = self.create_indicator_window(self.app, mon)
                except Exception as e:
                    print(f"Failed to create overlay window: {e}", file=sys.stderr)
                    continue
                self.id_to_win[id(mon)] = win

        # Close windows whose monitor has gone away. Skip removal before we have
        # created at least one window, so a transient empty result doesn't destroy
        # everything on the very first tick (e.g. when nothing is mapped yet).
        if self.id_to_win:
            gone = [w for mid, w in self.id_to_win.items() if mid not in current_ids]
            for w in gone:
                try:
                    w.close()
                except Exception:
                    pass
            self.id_to_win = {
                mid: w for mid, w in self.id_to_win.items() if mid in current_ids
            }

        # Windows stay visible on every monitor; the label itself composes the
        # RU text only while self.ru_active is set (see _indicator_markup()).

    def _poll_monitors(self):
        while True:
            GLib.idle_add(self._reconcile_monitors)
            time.sleep(3)

    def make_click_through(self, widget):
        surface = widget.get_native().get_surface()
        if surface:
            empty_region = cairo.Region()
            surface.set_input_region(empty_region)

    def update_visibility(self, idx):
        # Only the "RU" text depends on this; the Caps Lock indicator stays
        # visible on every monitor regardless of active layout.
        self.ru_active = (idx == 1)
        GLib.idle_add(self._refresh_all_labels)

    def listen_to_niri(self):
        socket_path = os.environ.get("NIRI_SOCKET")
        if not socket_path:
            return

        try:
            s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            s.connect(socket_path)
            s.sendall(b'"EventStream"\n')

            buffer = ""
            while True:
                data = s.recv(4096).decode('utf-8')
                if not data:
                    break
                buffer += data
                while "\n" in buffer:
                    line, buffer = buffer.split("\n", 1)
                    if not line.strip():
                        continue
                    try:
                        event = json.loads(line)
                        if "KeyboardLayoutSwitched" in event:
                            idx = event["KeyboardLayoutSwitched"]["idx"]
                            GLib.idle_add(self.update_visibility, idx)
                    except json.JSONDecodeError:
                        continue
        except Exception as e:
            print(f"Niri IPC connection error: {e}", file=sys.stderr)

    def run(self):
        self.app.run(None)

if __name__ == '__main__':
    app = TrueWaylandOverlay()
    app.run()
