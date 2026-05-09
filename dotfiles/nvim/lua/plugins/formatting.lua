local null_ls = require("null-ls")

------------------------------------------------------------
-- Formatters & Linters
------------------------------------------------------------
null_ls.setup({
  sources = {
    null_ls.builtins.formatting.prettier.with({
      filetypes = {
        "javascript",
        "json",
        "yaml",
        "markdown",
      },
    }),

    -- Bash
    null_ls.builtins.formatting.shfmt,

    -- Terraform / HCL
    null_ls.builtins.formatting.terraform_fmt,

    -- Docker
    null_ls.builtins.diagnostics.hadolint,

    -- YAML
    null_ls.builtins.diagnostics.yamllint,
  },

  ----------------------------------------------------------
  -- Auto‑format on save (safe + modern)
  ----------------------------------------------------------
  on_attach = function(client, bufnr)
    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({
        group = "LspFormatting",
        buffer = bufnr,
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,
            timeout_ms = 2000,
          })
        end,
      })
    end
  end,
})