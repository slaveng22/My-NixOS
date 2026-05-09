require("bufferline").setup({
  options = {
    mode = "buffers",
    close_command = "bdelete! %d",
    right_mouse_command = "bdelete! %d",
    offsets = {
      {
        filetype = "NvimTree",
        text = "File Explorer",
        highlight = "Directory",
        text_align = "left",
      },
    },
    diagnostics = "nvim_lsp",
    separator_style = "thin",
    always_show_bufferline = false,
  },
})

vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>d", "<cmd>bdelete<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })
vim.keymap.set("n", "<leader>bD", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Close unpinned buffers" })
