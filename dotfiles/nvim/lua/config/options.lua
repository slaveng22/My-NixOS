local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.signcolumn = "yes"
opt.clipboard = "unnamedplus"
opt.laststatus = 3
opt.cmdheight = 0

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

opt.termguicolors = true

-- Neovide
vim.g.neovide_cursor_animation_length = 0
vim.g.neovide_cursor_trail_length = 0
vim.g.neovide_cursor_antialiasing = false
vim.g.neovide_cursor_vfx_mode = ""
vim.o.guifont = "JetBrainsMono Nerd Font:h14"

-- Overwrite Neovide default font
if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h14"
end