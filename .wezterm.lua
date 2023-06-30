-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'AdventureTime'

config.default_prog = { '/usr/bin/zsh' }

config.use_ime=true;

-- ## Fonts
-- wezterm ls-fonts --list-systemで使えるフォントの一覧が設定ファイルに書きやすい形で出力される。
-- config.font = wezterm.font( {weight="Regular", stretch="Normal", italic=false})
config.font = wezterm.font_with_fallback {
  'MesloLGS NF',
}


config.font_size=11

local act = wezterm.action
config.leader = { key = 'b', mods = 'CTRL', timeout_milliseconds = 2000 }
config.keys = {
  {
    key = '|',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = '-',
    mods = 'LEADER',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  { key = 't', mods = 'SHIFT|CTRL', action = wezterm.action.SpawnTab 'CurrentPaneDomain'  },
  { key = 't', mods = 'LEADER',action = wezterm.action.SpawnTab 'CurrentPaneDomain', },
  { key = 'f', mods = 'LEADER', action = wezterm.action.ToggleFullScreen, },

  -- Ctrl+左矢印でカーソルを前の単語に移動
  {
    key = "LeftArrow",
    mods = "CTRL",
    action = act.SendKey { key = "b", mods = "META", },
  },
  -- Ctrl+右矢印でカーソルを次の単語に移動
  {
    key = "RightArrow",
    mods = "CTRL",
    action = act.SendKey { key = "f",mods = "META",   },
  },
  -- Ctrl+Backspaceで前の単語を削除
  {
    key = "Backspace",
    mods = "CTRL",
    action = act.SendKey { key = "w", mods = "CTRL",},
  },

  { key = "n", mods = "LEADER", action = wezterm.action.PaneSelect },
  { key = ']', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = '[', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = "c", mods = "LEADER", action = wezterm.action({ CopyTo = "Clipboard" }) },
  { key = "v", mods = "LEADER", action = wezterm.action({ PasteFrom = "Clipboard" }) },
  -- 
  -- https://github.com/wez/wezterm/issues/641
  { key = "q", mods = "LEADER", action = "ShowDebugOverlay" },
  { key = 'r', mods = 'LEADER|CTRL', action = wezterm.action.ReloadConfiguration, },
 -- 
  { key = "l", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
  { key = "h", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
  { key = "k", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
  { key = "j", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
}

config.hide_tab_bar_if_only_one_tab = true;
config.adjust_window_size_when_changing_font_size = false;

config.disable_default_key_bindings = true;

-- and finally, return the configuration to wezterm
return config

