lvim.log.level = "info"
lvim.format_on_save = true
lvim.transparent_window = true

lvim.leader = "space"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.view.width = 50

lvim.builtin.treesitter.auto_install = true
lvim.builtin.treesitter.ensure_installed = {
    "bash",
    "javascript",
    "json",
    "lua",
    "python",
    "typescript",
    "tsx",
    "css",
    "rust",
    "java",
    "yaml",
}

lvim.builtin.treesitter.ignore_install = { "haskell" }
lvim.builtin.treesitter.highlight.enabled = true

vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.hlsearch = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.guicursor = ""
vim.opt.writebackup = false
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.relativenumber = true
vim.opt.wrap = true
vim.opt.textwidth = 120
vim.opt.colorcolumn = 120
