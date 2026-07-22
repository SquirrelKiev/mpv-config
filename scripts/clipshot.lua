---Screenshot the video and copy it to the clipboard
---@author ObserverOfTime
---@license 0BSD

---@class ClipshotOptions
---@field type string
local o = {
    type = '' -- defaults to jpeg
}
require('mp.options').read_options(o, 'clipshot')

local platform = mp.get_property_native('platform')

---@param arg string
---@return fun()
local function clipshot(arg)
    return function()
        local res = mp.command_native({'screenshot', arg})
        if not res or not res.filename then return end
        
        local file = res.filename
        local cmd

        if platform == 'windows' then
            cmd = {
                'powershell', '-NoProfile', '-Command',
				'Add-Type -Assembly System.Windows.Forms;',
                string.format(
                    "$fileList = New-Object System.Collections.Specialized.StringCollection; [void]$fileList.Add('%s'); [Windows.Forms.Clipboard]::SetFileDropList($fileList)",
                    file:gsub("'", "''")
                )
            }
        elseif platform == 'darwin' then
            cmd = {
                'osascript', '-e', string.format(
                    'set the clipboard to (POSIX file %q)',
                    file, type
                )
            }
        else
            if os.getenv('XDG_SESSION_TYPE') == 'wayland' then
                cmd = {'wl-copy', '--type', 'text/uri-list', string.format('file://%s', file)}
            end
        end

        mp.command_native_async({'run', unpack(cmd)}, function(suc, _, err)
            mp.osd_message(suc and 'Copied screenshot to clipboard' or err, 1)
        end)
    end
end

mp.add_key_binding('f16',		'clipshot-subs',   clipshot('subtitles'))
mp.add_key_binding('shift+f16', 'clipshot-video',  clipshot('video'))
mp.add_key_binding('Alt+f16',	'clipshot-window', clipshot('window'))