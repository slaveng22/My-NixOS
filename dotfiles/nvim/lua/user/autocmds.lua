-- Absolute line numbers in insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function() vim.opt.relativenumber = false end,
})
vim.api.nvim_create_autocmd("InsertLeave", {
    callback = function() vim.opt.relativenumber = true end,
})

-- Highlight yanks
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("HighlightYank", { clear = true }),
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})
