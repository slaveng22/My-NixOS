local alpha = require("alpha")
local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
  " _   _        __      ___            ",
  "| \\ | |       \\ \\    / (_)           ",
  "|  \\| | ___  __\\ \\  / / _ _ __ ___   ",
  "| . ` |/ _ \\/ _ \\ \\/ / | | '_ ` _ \\  ",
  "| |\\  |  __/ (_) \\  /  | | | | | | | ",
  "|_| \\_|\\___|\\___/ \\/   |_|_| |_| |_| ",
  "",
}

dashboard.section.buttons.val = {
  dashboard.button("e", "  New file",    ":ene | startinsert<CR>"),
  dashboard.button("f", "  Open file",   ":lua require('fzf-lua').files()<CR>"),
  dashboard.button("o", "󰝰  Open folder", ":lua require('fzf-lua').fzf_exec('fdfind --type d . ' .. vim.env.HOME, { prompt = 'Folder> ', actions = { ['default'] = function(s) if s and s[1] then require('fzf-lua').files({ cwd = s[1] }) end end } })<CR>"),
  dashboard.button("g", "󰈞  Live grep",   ":lua require('fzf-lua').live_grep_native()<CR>"),
  dashboard.button("p", "󰔠  Projects",    ":lua require('telescope').extensions.projects.projects{}<CR>"),
  dashboard.button("l", "󰒲  Lazy",        ":Lazy<CR>"),
  dashboard.button("q", "󰩈  Quit",        ":qa<CR>"),
}

-- project.nvim: auto-detect and track git project roots
require("project_nvim").setup({
  detection_methods = { "pattern" },
  patterns = { ".git" },
  show_hidden = false,
  silent_chdir = true,
})

alpha.setup(dashboard.config)
