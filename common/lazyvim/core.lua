-- Managed by dotfiles: common/lazyvim/core.lua (deployed by `just lazyvim-config`)
-- LazyVim core configuration: colorscheme and base settings.
-- Plugin-specific configs go in their own files under plugins/.
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = vim.o.background == "light"
        and "catppuccin-latte"
        or "catppuccin-frappe",
    },
  },
}
