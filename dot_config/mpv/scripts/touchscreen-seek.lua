require 'mp.options'

local options = {
    -- не работает как должно, 5 = 10сек. Меньше 5 все равно скипает на 10
    step = 5, 
	sub_step = 0.5,
}

function touch_seek()
    local pos = get_mouse_area()
    local step = options.step
	local sub_step = options.sub_step

    if pos == 'top_middle' then
        toggle_fullscreen()
	elseif pos == 'top_left' then
        mp.command('add sub-delay ' .. sub_step)
    elseif pos == 'top_right' then
        mp.command('add sub-delay ' .. -sub_step)
    elseif pos == 'bot_left' then
        mp.commandv('seek', -1*step)
    elseif pos == 'bot_right' then
        mp.commandv('seek', step)
    elseif pos == 'bot_middle' then
        toggle_pause()
    end
end

function get_mouse_area()
    local mouse_x,mouse_y = mp.get_mouse_pos()
    local winX,winY = mp.get_property('osd-width'), mp.get_property('osd-height')
    
	if mouse_y < winY/2 then
		if mouse_x < winX/3 then
            return 'top_left'
        elseif mouse_x < winX/3*2 then
            return 'top_middle'
        else
            return 'top_right'
		end
    end
    
	if mouse_x < winX/3 then
        return 'bot_left'
    elseif mouse_x < winX/3*2 then
        return 'bot_middle'
    else
        return 'bot_right'
    end
end

function toggle_fullscreen()
    local screen_stat = mp.get_property('fullscreen')

    if screen_stat == 'yes' then
        screen_stat = 'no'
    else
        screen_stat = 'yes'
    end

    mp.set_property('fullscreen', screen_stat)
end

function toggle_pause()
    local pause = mp.get_property_native("pause")
    mp.set_property_native("pause", not pause)
end


mp.add_key_binding(nil, "touchscreen-seek", touch_seek)
mp.msg.info("Loaded touchscreen-seek Lua flavor")