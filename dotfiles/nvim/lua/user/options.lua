-- General Vim options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.g.clipboard = {
    copy = {
            ["*"] = { "wl-copy" },
            ["+"] = { "wl-copy" },
    },
    paste = {
            ["*"] = { "wl-paste", "--no-newline" },
            ["+"] = { "wl-paste", "--no-newline" },
    },
    cache_enabled = 0,
    }
vim.opt.clipboard = "unnamedplus"


-- Leader key
vim.g.mapleader = " "
