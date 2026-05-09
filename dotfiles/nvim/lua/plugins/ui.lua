local M = {}

function M.colorscheme()
  vim.g.everforest_background = "hard"
  vim.cmd.colorscheme("everforest")
end

function M.lualine()
  require("lualine").setup({
    options = {
      theme = "auto",
      icons_enabled = true,
      globalstatus = true,
      section_separators = "",
      component_separators = "",
    },
  })
end

function M.noice()
  require("noice").setup({
    views = {
      cmdline_popup = {
        position = { row = "10%", col = "50%" },
      },
    },
    cmdline = {
      enabled = true,
      view = "cmdline_popup",
      format = {
        cmdline = { pattern = "^:", icon = "", lang = "vim" },
        search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
        search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
      },
    },
    lsp = {
      progress = { enabled = true },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    presets = {
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  })

  -- Linux-safe notify hookup
  local ok, notify = pcall(require, "notify")
  if ok then
    vim.notify = notify
  end
end

return M