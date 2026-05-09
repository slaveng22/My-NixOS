-- Mason: manages LSP binaries
require("mason").setup()

require("mason-lspconfig").setup({
  ensure_installed = {
    -- Core
    "lua_ls",
    "bashls",
    "jsonls",
    "yamlls",

    -- Docs
    "marksman",
    "harper_ls",
  },
})

-- Capabilities for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

------------------------------------------------------------
-- Modern Neovim 0.11+ LSP configuration
------------------------------------------------------------
local servers = {

  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  },

  bashls = {},
  jsonls = {},
  yamlls = {},

  marksman = {},
  harper_ls = {
    settings = {
      ["harper-ls"] = {
        userDictPath = vim.fn.stdpath("data") .. "/harper/user_dict.txt",
      },
    },
  },
}

for name, config in pairs(servers) do
  config.capabilities = capabilities
  vim.lsp.config(name, config)
  vim.lsp.enable(name)
end

------------------------------------------------------------
-- IDE‑style LSP keymaps
------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    map("gd",         vim.lsp.buf.definition,      "Go to definition")
    map("K",          vim.lsp.buf.hover,            "Hover docs")
    map("<leader>ca", vim.lsp.buf.code_action,      "Code action")
    map("<leader>rn", vim.lsp.buf.rename,           "Rename")
    map("[d",         vim.diagnostic.goto_prev,     "Prev diagnostic")
    map("]d",         vim.diagnostic.goto_next,     "Next diagnostic")
    map("<leader>cd", vim.diagnostic.open_float,    "Show diagnostic")
  end,
})
