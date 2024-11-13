-- by SquirrelKiev :chatting:

local utils = require "mp.utils"

local function print(s, duration)
    mp.msg.info(s)
    mp.osd_message(s, duration)
end

local has_set_start_pos = false
local start_pos = 0
local end_pos = 0

local function get_current_pos()
    local time = mp.get_property_number("time-pos")

    if not has_set_start_pos then
        start_pos = time
        has_set_start_pos = true
        print("set start pos to " .. start_pos .. ". (" .. start_pos .. " / " .. end_pos .. ")")
    else
        end_pos = time
        has_set_start_pos = false
        print("set end pos to " .. end_pos .. ". (" .. start_pos .. " / " .. end_pos .. ")")
    end

end

local function strip_prefix(str)
    if str:sub(1, 2) == ".\\" then
        return str:sub(3)
    else
        return str
    end
end

-- theres probably a million other edge cases im not aware of but ive not found them yet
function escapeString(str)
    local escapedStr = string.gsub(str, '\\', '/')
    return escapedStr
  end

  function escapeStringVf(str)
    local escapedStr = string.gsub(str, '\\', '/')
    escapedStr = string.gsub(escapedStr, '"', '\\"')
    escapedStr = string.gsub(escapedStr, ':', '\\:')
    return escapedStr
  end

local function clip()
    video_path = escapeString(strip_prefix(mp.get_property("path")))
    path_no_ext = mp.get_property("filename/no-ext")
    working_dir = mp.get_property("working-directory")

    escaped_video_path = escapeStringVf(video_path)

    local args = {
        "ffmpeg",
        "-nostdin", "-y",
        "-loglevel", "error",
        "-i", video_path,
        "-ss", tostring(start_pos),
        "-to", tostring(end_pos),
        "-vf", "subtitles='" .. escaped_video_path .. "'",
        utils.join_path(working_dir, path_no_ext .. "-" .. start_pos .. "-" .. end_pos .. ".mp4")
    }

    print("cooking, please wait... " .. escaped_video_path, 2)

    mp.command_native_async({
        name = "subprocess",
        args = args,
        playback_only = false
    }, function() print("done'd. if you see nothing, check terminal output") end)
end


KEY_SET_POS = "c"
KEY_CLIP_THING = "C"

mp.add_key_binding(KEY_SET_POS, "clipper-set-pos", get_current_pos)
mp.add_key_binding(KEY_CLIP_THING, "clipper-make-clip", clip)