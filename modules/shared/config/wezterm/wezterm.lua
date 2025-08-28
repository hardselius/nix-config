-- Pull in the wezterm API.
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font("Hack")
config.enable_scroll_bar = true

function scheme_for_appearance(appearance)
	if appearance:find 'Dark' then
		return 'nightfox'
	else
		return 'dawnfox'
	end
end

wezterm.on('window-config-reloaded', function(window, pane)
	local overrides = window:get_config_overrides() or {}
	local appearance = window:get_appearance()
	local scheme = scheme_for_appearance(appearance)
	if overrides.color_scheme ~= scheme then
		overrides.color_scheme = scheme
		window:set_config_overrides(overrides)
	end
end)

return config
