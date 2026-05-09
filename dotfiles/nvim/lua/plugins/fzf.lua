local map = vim.keymap.set

require("fzf-lua").setup({})

map("n", "<leader>f", function()
  require("fzf-lua").files()
end, { desc = "Find files" })

map("n", "<leader>r", function()
  require("fzf-lua").live_grep_native()
end, { desc = "Live grep" })

map("n", "<leader>p", function()
  require("telescope").extensions.projects.projects{}
end, { desc = "Projects" })
