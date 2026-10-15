#!/usr/bin/env python3

import json
import os
import socket
import sys
import threading
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
        self.windows = []

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
        # Bold high-contrast red label
        label.set_markup('<span font="Bold 22" foreground="#FF5555">RU</span>')
        win.set_child(label)
        
        win.present()
        win.set_visible(False)
        
        return win

    def on_activate(self, app):
        # Apply transparency rules globally to the application's render loop
        self.apply_transparent_theme()
        
        display = Gdk.Display.get_default()
        monitors = display.get_monitors()
        
        for i in range(monitors.get_n_items()):
            monitor = monitors.get_item(i)
            win = self.create_indicator_window(app, monitor)
            self.windows.append(win)

        threading.Thread(target=self.listen_to_niri, daemon=True).start()

    def make_click_through(self, widget):
        surface = widget.get_native().get_surface()
        if surface:
            empty_region = cairo.Region()
            surface.set_input_region(empty_region)

    def update_visibility(self, idx):
        show_overlay = (idx == 1)
        for win in self.windows:
            win.set_visible(show_overlay)

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

