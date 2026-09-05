-- mpv simple geometry script for second monitor
-- Save as: ~/.config/mpv/scripts/simple-geometry.lua

local mp = require 'mp'

-- Window size
local width = 925
local height = 520

-- Second monitor positioning (adjust these values based on your monitor setup)
-- For a typical 1920x1080 second monitor to the right of main monitor:
local second_monitor_x = 2560  -- X position where second monitor starts
local second_monitor_y = 0     -- Y position where second monitor starts
local second_monitor_width = 1920  -- Width of second monitor
local second_monitor_height = 1080 -- Height of second monitor

-- Function to set geometry
function set_geometry(x, y, position_name)
    local geometry = string.format("%dx%d+%d+%d", width, height, x, y)
    mp.set_property("geometry", geometry)
    mp.osd_message("Position: " .. position_name)
end

-- Top-left of second monitor
function set_top_left()
    local x = second_monitor_x
    local y = second_monitor_y
    set_geometry(x, y, "Second Monitor Top-Left")
end

-- Top-right of second monitor
function set_top_right()
    local x = second_monitor_x + width
    local y = second_monitor_y
    set_geometry(x, y, "Second Monitor Top-Right")
end

-- Bottom-left of second monitor
function set_bottom_left()
    local x = second_monitor_x
    local y = second_monitor_y + height
    set_geometry(x, y, "Second Monitor Bottom-Left")
end

-- Bottom-right of second monitor
function set_bottom_right()
    local x = second_monitor_x + width
    local y = second_monitor_y + height
    set_geometry(x, y, "Second Monitor Bottom-Right")
end

-- Set up key bindings
mp.add_key_binding("Alt+1", "second-monitor-top-left", set_top_left)
mp.add_key_binding("Alt+2", "second-monitor-bottom-left", set_bottom_left)
mp.add_key_binding("Alt+3", "second-monitor-top-right", set_top_right)
mp.add_key_binding("Alt+4", "second-monitor-bottom-right", set_bottom_right)

mp.osd_message("Simple geometry script loaded - Use Alt+1 to Alt+4 for second monitor positions")