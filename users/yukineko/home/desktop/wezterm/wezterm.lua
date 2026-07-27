local wezterm = require 'wezterm'
wezterm.add_to_config_reload_watch_list(wezterm.config_dir)

local function file_exists(name)
    local f = io.open(name, 'r')
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

local preview_file = wezterm.config_dir .. '/preview.lua'
if file_exists(preview_file) then
    return dofile(preview_file)
end

local config = wezterm.config_builder()
config.automatically_reload_config = true
config.use_ime = true
config.window_background_opacity = 0.75
config.hide_tab_bar_if_only_one_tab = true
-- config.color_scheme = 'Noctalia'
config.color_scheme = 'OneHalfDark'
config.font = wezterm.font_with_fallback {
    'JetBrainsMono Nerd Font',
    'PlemolJP HS'
}

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.window_padding = {
  left = '1.5cell',
  right = '1.5cell',
  top = '0.75cell',
  bottom = '0.75cell',
}

return config