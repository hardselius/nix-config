-- Pull in the wezterm API.
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font("Aporetic Sans Mono")
config.enable_scroll_bar = true
config.color_schemes = {
	['alabaster_dark'] = {
		foreground = '#cecece',
		background = '#0e1415',
		cursor_bg = '#cd974b',
		cursor_border = '#cd974b',
		cursor_fg = '#0e1415',
		selection_bg = '#293334',
		selection_fg = '#cecece',
		ansi = { '#000000', '#d2322d', '#6abf40', '#cd974b', '#217EBC', '#9B3596', '#178F79', '#cecece' },
		brights = { '#333333', '#c33c33', '#95cb82', '#dfdf8e', '#71aed7', '#cc8bc9', '#47BEA9', '#ffffff' },
	},
	['alabaster_light'] = {
		foreground = "#000000",
		background = "#f7f7f7",
		cursor_bg = "#007acc",
		cursor_border = "#007acc",
		cursor_fg = "#bfdbfe",
		selection_bg = "#bfdbfe",
		selection_fg = "#000000",
		ansi = {"#000000","#aa3731","#448c27","#cb9000","#325cc0","#7a3e9d","#0083b2","#f7f7f7"},
		brights = {"#777777","#f05050","#60cb00","#ffbc5d","#007acc","#e64ce6","#00aacb","#f7f7f7"},
	},
}

function scheme_for_appearance(appearance)
	if appearance:find 'Dark' then
		return 'alabaster_dark'
	else
		return 'alabaster_light'
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
