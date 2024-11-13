local saved_time = nil

function format_time(seconds)
    if not seconds then return "00:00:00.000" end
    
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    local milliseconds = math.floor((seconds % 1) * 1000)
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d.%03d", hours, minutes, secs, milliseconds)
    else
        return string.format("%02d:%02d.%03d", minutes, secs, milliseconds)
    end
end

function save_timestamp()
    saved_time = mp.get_property_number("time-pos")
    local time_str = format_time(saved_time)
    mp.osd_message(string.format("Saved position: %s", time_str))
end

function load_timestamp()
    if saved_time then
        mp.set_property_number("time-pos", saved_time)
        local time_str = format_time(saved_time)
        mp.osd_message(string.format("Loaded position: %s", time_str))
    else
        mp.osd_message("No position saved")
    end
end

mp.add_key_binding("b", "save_timestamp", save_timestamp)
mp.add_key_binding("n", "load_timestamp", load_timestamp)