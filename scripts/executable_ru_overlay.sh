#!/usr/bin/env python3

import json
import subprocess
import sys
import threading
import warnings

# evdev gives us real keyboard events (Caps Lock LED) without sleeping/polling.
import evdev
from evdev import ecodes
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
        # Which layout is currently active ("RU" only, per _indicator_markup()).
        self.ru_active = False
        # Caps-Lock state, driven by the evdev event loop below.
        self.caps_lock = False
        # Substrings that identify a Russian layout (case-insensitive).
        self.russian_markers = ("rus", "рус")

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
        # Renders the current indicator: an optional ⇧ (Caps Lock) immediately
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

        # Detect Caps Lock via real keyboard LED events (blocks on fd, no polling).
        threading.Thread(target=self.watch_caps_lock, daemon=True).start()

        # Subscribe to Niri's IPC stream for layout switches (also reflects the
        # current layout at startup).
        threading.Thread(target=self.watch_niri_layouts, daemon=True).start()

        # Establish presence immediately: if nothing is active, hide the windows we
        # just created. See sync_state().
        GLib.idle_add(self.sync_state)

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

        # Windows are shown/hidden on demand (see sync_state()); presence is not
        # tied to layout -- only the "RU" text content is.

    def make_click_through(self, widget):
        surface = widget.get_native().get_surface()
        if surface:
            empty_region = cairo.Region()
            surface.set_input_region(empty_region)

    # --- Indicator label ------------------------------------------------------

    def _indicator_markup(self):
        """Compose the bottom indicator label from current state.

        Returns an optional ⇧ (Caps Lock) immediately to the left of "RU", e.g.:
          EN, caps off  -> ""   EN, caps on -> "⇧"
          RU, caps off  -> "RU"          RU, caps on -> "⇧ RU"

        Uses no leading/trailing spacing when a part is empty.
        """
        parts = []
        if self.caps_lock:
            parts.append('<span font="Bold 22" foreground="#DDDDDD">\u21ea</span>')
        if self.ru_active:
            parts.append('<span font="Bold 22" foreground="#FF5555">RU</span>')
        return ' '.join(parts)

    def sync_state(self):
        """Set markup and visibility on every window at once.

        Runs on the GTK main thread after a Caps Lock or layout change (and once
        at launch). If both conditions are off there is nothing to show, so we
        *hide* the windows entirely -- this avoids the compositor refusing to
        paint a transparent surface, which would otherwise leave stale content.
        Otherwise we set the markup and re-present the windows immediately.
        """
        any_active = self.ru_active or self.caps_lock
        for win in list(self.id_to_win.values()):
            child = win.get_child()
            if getattr(child, "set_markup", None) is not None:
                try:
                    child.set_markup(self._indicator_markup())
                except Exception as e:
                    print(f"ru_overlay: set_markup error: {e}", file=sys.stderr)
            if any_active:
                win.present()
            else:
                win.hide()

    def _looks_russian(self, name):
        n = (name or "").lower().strip()
        return any(tok in n for tok in self.russian_markers)

    def _set_active_layout(self, name):
        # Only the "RU" text depends on this; presence of anything else (caps) is
        # independent. Reflect both markup and visibility immediately via sync.
        self.ru_active = self._looks_russian(name)
        GLib.idle_add(self.sync_state)

    def _resolve_layout_name(self, idx):
        if not isinstance(idx, int):
            return None
        try:
            out = subprocess.run(
                ["niri", "msg", "--json", "keyboard-layouts"],
                capture_output=True, text=True, check=True, timeout=2,
            )
            data = json.loads(out.stdout)
            names = data.get("names")
            if isinstance(names, list) and 0 <= idx < len(names):
                return names[idx]
        except Exception as e:
            print(f"ru_overlay: layout name lookup failed: {e}", file=sys.stderr)
        return None

    def _apply_current_layout(self):
        # Reflect the currently active layout at launch (best-effort).
        try:
            out = subprocess.run(
                ["niri", "msg", "--json", "keyboard-layouts"],
                capture_output=True, text=True, check=True, timeout=2,
            )
            data = json.loads(out.stdout)
        except Exception as e:
            print(f"ru_overlay: initial layout query failed: {e}", file=sys.stderr)
            return

        names = data.get("names")
        idx = (data.get("layout_idx", None)
               or data.get("current_idx", None)
               or data.get("default_idx", None))
        if isinstance(names, list) and isinstance(idx, int) and 0 <= idx < len(names):
            GLib.idle_add(self._set_active_layout, names[idx])

    def watch_niri_layouts(self):
        """Background thread: subscribe to Niri's IPC stream for layout switches.

        Starts an `niri msg event-stream` subprocess and yields on each
        KeyboardLayoutSwitched, translating the idx into a layout name (or using
        one Niri includes in the payload). Runs until the subprocess ends.
        """
        proc = subprocess.Popen(
            ["niri", "msg", "--json", "event-stream"],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
        )
        self._apply_current_layout()  # reflect reality at launch
        try:
            for line in proc.stdout:
                line = line.strip()
                if not line:
                    continue
                try:
                    event = json.loads(line)
                except json.JSONDecodeError:
                    continue
                kl = event.get("KeyboardLayoutSwitched")
                if isinstance(kl, dict):
                    idx = kl.get("idx")
                    name = kl.get("name") or self._resolve_layout_name(idx)
                    GLib.idle_add(self._set_active_layout, name)
        except Exception as e:
            print(f"ru_overlay: niri layout error: {e}", file=sys.stderr)
        finally:
            proc.terminate()
            proc.wait()

    def watch_caps_lock(self):
        """Background thread: detect Caps Lock via a keyboard LED event loop.

        Finds the first input device that exposes CAPSL, then blocks on its fd
        with read_loop (no polling / sleep). Each EV_LED/LED_CAPSL flip updates
        self.caps_lock and repaints (and re-present/hides) on the GTK main thread.
        Returns early if no suitable device is readable. Requires membership in
        the `input` group.
        """
        dev = None
        for path in evdev.list_devices():
            try:
                cand = evdev.InputDevice(path)
            except (OSError, PermissionError):
                continue
            if ecodes.LED_CAPSL in (cand.capabilities().get(ecodes.EV_LED, []) or []):
                dev = cand
                break

        if dev is None:
            print("ru_overlay: no keyboard with Caps Lock LED found; "
                  "indicator disabled", file=sys.stderr)
            return

        try:
            for event in dev.read_loop():
                if event.type == ecodes.EV_LED and event.code == ecodes.LED_CAPSL:
                    state = bool(event.value)
                    if state != self.caps_lock:
                        self.caps_lock = state
                        GLib.idle_add(self.sync_state)
        except Exception as e:
            print(f"ru_overlay: caps event loop error: {e}", file=sys.stderr)

    def run(self):
        self.app.run(None)


if __name__ == '__main__':
    app = TrueWaylandOverlay()
    app.run()
