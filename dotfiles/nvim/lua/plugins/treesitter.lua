require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash",
    "json",
    "yaml",
    "markdown",
  },
  highlight = { enable = true },
  indent = { enable = true },
})
