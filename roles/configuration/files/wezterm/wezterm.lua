local wezterm = require "wezterm"

return {
  window_decorations = "NONE",
  window_background_opacity = 0.95,
  hide_tab_bar_if_only_one_tab = true,
  color_scheme = "nord",
  initial_cols = 200,
  initial_rows = 55,

  font = wezterm.font "FiraCode Nerd Font",
  font_size = 9,
  default_cursor_style = "BlinkingUnderline",
}
