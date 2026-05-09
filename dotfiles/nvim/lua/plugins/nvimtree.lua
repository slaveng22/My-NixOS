require("nvim-tree").setup({
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    api.config.mappings.default_on_attach(bufnr)
    local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }
    vim.keymap.set("n", "l", api.node.open.edit, opts)
    vim.keymap.set("n", "h", api.node.navigate.parent_close, opts)
  end,

  disable_netrw = true,
  hijack_netrw = true,
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = true,
  },

  view = {
    width = 32,
    side = "left",
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
      },
    },
  },

  filters = {
    dotfiles = false,
  },

  git = {
    enable = true,
    ignore = false,
  },
})

-- Keymaps
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer" })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<cr>", { desc = "Focus explorer" })