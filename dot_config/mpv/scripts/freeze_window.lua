local toggleflag = true

function freeze_window()
    if toggleflag then
		local ww, wh = mp.get_osd_size()
		mp.set_property("geometry", string.format("%dx%d", ww, wh))
		mp.osd_message("window size frozen")
		toggleflag = not toggleflag
	else
		mp.set_property("geometry", "")
		mp.osd_message("window size un-frozen")
		toggleflag = not toggleflag
	end
end

mp.add_key_binding('KP5', 'freeze_window', freeze_window)
mp.add_key_binding('Shift+Y', 'freeze_window', freeze_window)