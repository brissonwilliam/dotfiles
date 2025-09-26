local wezterm = require 'wezterm'
local config = {}
local host = wezterm.hostname()
local isThinkpad = (host == 'ThinkPad-P15v')

-- startup configs
-- config.default_prog = {"wsl", "--cd", "~"} -- might wanna disable this for linux based OS
-- config.default_prog = {"/usr/bin/zsh"}
config.default_cwd = '~'
config.max_fps = 144

function setupFonts(config)
    -- config.font = wezterm.font('DejaVuSansM Nerd Font Mono')

    -- for openGL render
    -- config.font = wezterm.font('IosevkaCustomMono', {weight='Regular'})
    -- config.freetype_render_target="Light"

    -- for webGpu render
    config.freetype_render_target="Normal"
    config.font = wezterm.font('IosevkaCustomMono', {weight='Regular'})

    config.font_size = 11
    config.cell_width=0.9

    if isThinkpad then
        config.font_size = 10.8
        config.cell_width = 0.9
        config.freetype_render_target="Light"
        -- config.freetype_render_target="HorizontalLcd"
    end
end
setupFonts(config)


function setupRenderer(config)
    -- renderer
    config.enable_wayland = true
    -- config.front_end = 'OpenGL'
    config.front_end = "WebGpu"
    config.webgpu_power_preference = "HighPerformance"
    -- config.window_decorations = "RESIZE"

    if isThinkpad then
        -- on gnome there's a window management issue, no resize or title bar
        -- https://github.com/wez/wezterm/issues/5931
        -- edit: seems to be fixed with nvidia 560 driver, though no title bars!

        -- seems to be fixed on 20240812 build or later, or with more recent gpu driver
        -- Integrated buttons makes bad window framing, waiting for fix in:
        -- https://github.com/wez/wezterm/pull/5971
    end
end
setupRenderer(config)

function setupWindow(config)
    config.window_padding = {
      left = 0,
      right = 0,
      top = 0,
      bottom = 0,
    }

    config.hide_tab_bar_if_only_one_tab = true
    config.initial_rows = 52
    config.initial_cols = 200

    config.exit_behavior = 'Close'
    config.window_close_confirmation = 'NeverPrompt'
end
setupWindow(config)

wezterm.on('format-window-title', function(tab, pane, tabs, panes, config)
  -- by default, this computes the pane index, window index and stuff. Since we use tmux, no use here
    local title = basename(pane.foreground_process_name)
	if title == '' then
		return 'Wezterm'
	end
	return title
end)
function basename(s)
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

function setupColors(config)
    config.colors = {
        -- dark bg
        background = '#100d0a',
        -- soft orange bg
        -- background= '#23211c',
        -- soft blue bg
        -- background = '#1c1f23',
        -- magenta bg
        -- background = '#1d171d',
        cursor_bg = '#dddddd',
        foreground = '#dddddd',
        ansi = {
            '#000000',
            '#cc0403',
            '#19cb00',
            '#cecb00',
            '#0d73cc',
            '#cb1ed1',
            '#0dcdcd',
            '#dddddd',
        },
        brights = {
            '#767676',
            '#f2201f',
            '#23fd00',
            '#fffd00',
            '#1a8fff',
            '#fd28ff',
            '#14ffff',
            '#ffffff',
        }	
    }
    end
setupColors(config)

function setupKeyboard(config)
    -- keybind configs
    local act = wezterm.action
    config.disable_default_key_bindings = true
    config.keys = {
        {key = "c", mods="CTRL|SHIFT", action = act.CopyTo("Clipboard")},
        {key = "v", mods="CTRL|SHIFT", action = act.PasteFrom("Clipboard")},
        {key = "Enter", mods="ALT", action = act.ToggleFullScreen},
        {key = "m", mods = "CTRL", action = act.SendString('¤') },
        {key = "i", mods = "CTRL", action = act.SendString('✔') },
        {key = "=", mods="CTRL", action = act.IncreaseFontSize },
        {key = "-", mods="CTRL", action = act.DecreaseFontSize },
        {key = "0", mods="CTRL", action = act.ResetFontSize },
    }
    -- keyboard inputs are faster with this off
    -- config.use_ime = false
end
setupKeyboard(config)

return config
