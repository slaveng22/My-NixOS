-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- Always cd to opened file
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.buftype == "terminal" then return end
    local file = vim.api.nvim_buf_get_name(0)
    if file ~= "" then
      vim.cmd("lcd " .. vim.fn.fnamemodify(file, ":h"))
    end
  end,
})

-- Relative numbers toggle
vim.api.nvim_create_autocmd("InsertEnter", {
  callback = function()
    vim.opt.relativenumber = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    vim.opt.relativenumber = true
  end,
})