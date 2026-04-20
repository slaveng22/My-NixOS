-- Smart buffer close functions
local function smart_quit()
    local bufnr = vim.api.nvim_get_current_buf()
    local buffers = vim.fn.getbufinfo({ buflisted = 1 })

    if #buffers == 1 then
        vim.cmd("qa")
    else
        vim.cmd("bd " .. bufnr)
    end
end

local function save_and_quit()
    vim.cmd("write")
    smart_quit()
end

-- Leader key mappings
vim.keymap.set("n", "<leader>q", smart_quit, { desc = "Close buffer (smart)" })
vim.keymap.set("n", "<leader>x", save_and_quit, { desc = "Save and close buffer" })
vim.keymap.set("n", "<leader>w", ":write<CR>", { desc = "Save buffer" })

-- Create new line above/below current line
vim.keymap.set("n", "gO", "<Cmd>execute 'normal!' v:count1 . 'O'<CR>")
vim.keymap.set("n", "go", "<Cmd>execute 'normal!' v:count1 . 'o'<CR>")
