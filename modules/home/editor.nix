{ pkgs, unstable, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # LSP binaries (replaces mason)
    extraPackages = with pkgs; [
      lua-language-server
      bash-language-server
      vscode-langservers-extracted  # jsonls
      yaml-language-server
      marksman
      harper
      # formatters
      prettier
      shfmt
      terraform
      hadolint
      yamllint
    ];

    plugins = with pkgs.vimPlugins; [
      # Colorscheme
      everforest
      # UI
      lualine-nvim
      bufferline-nvim
      noice-nvim
      nui-nvim
      nvim-notify
      alpha-nvim
      nvim-web-devicons
      # Navigation
      fzf-lua
      nvim-tree-lua
      project-nvim
      # LSP + completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      luasnip
      # Treesitter
      (nvim-treesitter.withPlugins (p: with p; [ bash json yaml markdown lua ]))
      # Formatting/linting
      none-ls-nvim
      # Git
      lazygit-nvim
      # Editing
      comment-nvim
      toggleterm-nvim
    ];

    extraLuaConfig = ''
      -- ── Options ──────────────────────────────────────────────────────────
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      local opt = vim.opt
      opt.number = true
      opt.relativenumber = true
      opt.mouse = "a"
      opt.signcolumn = "yes"
      opt.clipboard = "unnamedplus"
      opt.laststatus = 3
      opt.cmdheight = 0
      opt.tabstop = 2
      opt.shiftwidth = 2
      opt.softtabstop = 2
      opt.expandtab = true
      opt.termguicolors = true
      vim.opt.more = false

      vim.g.neovide_cursor_animation_length = 0
      vim.g.neovide_cursor_trail_length = 0
      vim.g.neovide_cursor_antialiasing = false
      vim.g.neovide_cursor_vfx_mode = ""
      vim.o.guifont = "JetBrainsMono Nerd Font:h14"

      -- ── Autocmds ─────────────────────────────────────────────────────────
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
        end,
      })
      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          if vim.bo.buftype == "terminal" then return end
          local file = vim.api.nvim_buf_get_name(0)
          if file ~= "" then vim.cmd("lcd " .. vim.fn.fnamemodify(file, ":h")) end
        end,
      })
      vim.api.nvim_create_autocmd("InsertEnter", { callback = function() vim.opt.relativenumber = false end })
      vim.api.nvim_create_autocmd("InsertLeave", { callback = function() vim.opt.relativenumber = true end })

      -- ── Keymaps ──────────────────────────────────────────────────────────
      local map = vim.keymap.set
      local o = { noremap = true, silent = true }
      map("n", "go", "o<Esc>k", o)
      map("n", "gO", "O<Esc>j", o)
      map("x", ">", ">gv", o)
      map("x", "<", "<gv", o)
      map("x", "p", '"_dP', o)
      map("n", "<leader>h", "<cmd>nohlsearch<cr>", o)
      map("n", "<leader>g", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
      map("n", "<leader>q", function()
        if vim.fn.confirm("Really quit?", "&Yes\n&No", 2) == 1 then vim.cmd("q!") end
      end, { desc = "Quit (!)" })
      map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer" })
      map("n", "<leader>o", "<cmd>NvimTreeFocus<cr>",  { desc = "Focus explorer" })
      map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
      map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
      map("n", "<leader>d", "<cmd>bdelete<cr>",         { desc = "Close buffer" })
      map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin buffer" })
      map("n", "<leader>bD", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Close unpinned" })
      map("t", "<C-t>", "<cmd>ToggleTerm<cr>", { desc = "Toggle terminal" })
      map("n", "<leader>f", function() require("fzf-lua").files() end,              { desc = "Find files" })
      map("n", "<leader>r", function() require("fzf-lua").live_grep_native() end,   { desc = "Live grep" })
      map("n", "<leader>p", function() require("project.extensions.fzf-lua").run_fzf_lua() end, { desc = "Projects" })

      -- Smart save
      local function smart_write()
        local bufname = vim.api.nvim_buf_get_name(0)
        local cwd = vim.fn.getcwd()
        local abs = vim.fn.fnamemodify(bufname, ":p")
        local cwd_slash = cwd:sub(-1) ~= "/" and cwd .. "/" or cwd
        if bufname ~= "" and abs:sub(1, #cwd_slash) == cwd_slash and vim.fn.filereadable(abs) == 1 then
          vim.cmd("write")
        else
          local input = vim.fn.input("Save as: ", vim.fn.fnamemodify(bufname, ":t"), "file")
          if input ~= "" then
            local path = input:sub(1,1) == "/" and input or (cwd .. "/" .. input)
            vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
            vim.cmd("saveas! " .. vim.fn.fnameescape(path))
          end
        end
      end
      map("n", "<leader>w", smart_write, { desc = "Smart write" })
      map("n", "<leader>x", function() smart_write() vim.cmd("bd") end, { desc = "Write and close" })

      -- ── Colorscheme ──────────────────────────────────────────────────────
      vim.g.everforest_background = "medium"
      vim.g.neovide_opacity = 0.95
      vim.cmd.colorscheme("everforest")
      vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#2d353b" })
      require("notify").setup({ background_colour = "#2d353b" })

      -- ── Lualine ──────────────────────────────────────────────────────────
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = true,
          globalstatus = true,
          section_separators = "",
          component_separators = "",
        },
      })

      -- ── Bufferline ───────────────────────────────────────────────────────
      require("bufferline").setup({
        options = {
          mode = "buffers",
          close_command = "bdelete! %d",
          right_mouse_command = "bdelete! %d",
          offsets = {{ filetype = "NvimTree", text = "File Explorer", highlight = "Directory", text_align = "left" }},
          diagnostics = "nvim_lsp",
          separator_style = "thin",
          always_show_bufferline = false,
        },
      })

      -- ── Noice ────────────────────────────────────────────────────────────
      require("noice").setup({
        views = { cmdline_popup = { position = { row = "10%", col = "50%" } } },
        cmdline = {
          enabled = true,
          view = "cmdline_popup",
          format = {
            cmdline    = { pattern = "^:", icon = "", lang = "vim" },
            search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
            search_up   = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          },
        },
        lsp = {
          progress = { enabled = true },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = { long_message_to_split = true, lsp_doc_border = true },
      })
-- ── Dashboard ────────────────────────────────────────────────────────
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        " _   _        __      ___            ",
        "| \\ | |       \\ \\    / (_)           ",
        "|  \\| | ___  __\\ \\  / / _ _ __ ___   ",
        "| . ` |/ _ \\/ _ \\ \\/ / | | '_ ` _ \\  ",
        "| |\\  |  __/ (_) \\  /  | | | | | | | ",
        "|_| \\_|\\___|\\___/ \\/   |_|_| |_| |_| ",
        "",
      }
      dashboard.section.buttons.val = {
        dashboard.button("e", "  New file",    ":ene | startinsert<CR>"),
        dashboard.button("f", "  Open file",   ":lua require('fzf-lua').files()<CR>"),
        dashboard.button("g", "󰈞  Live grep",   ":lua require('fzf-lua').live_grep_native()<CR>"),
        dashboard.button("p", "󰔠  Projects",    ":lua require('project.extensions.fzf-lua').run_fzf_lua()<CR>"),
        dashboard.button("q", "󰩈  Quit",        ":qa<CR>"),
      }
      require("project").setup({
        lsp = { enabled = false },
        patterns = { ".git" },
        show_hidden = false,
        silent_chdir = true,
      })
      alpha.setup(dashboard.config)

      -- ── FZF-lua ──────────────────────────────────────────────────────────
      require("fzf-lua").setup({})

      -- ── LazyGit ──────────────────────────────────────────────────────────
      -- (keymaps already set above)

      -- ── Comment ──────────────────────────────────────────────────────────
      require("Comment").setup({})

      -- ── LSP ──────────────────────────────────────────────────────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local servers = {
        lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
        bashls = {},
        jsonls = {},
        yamlls = {},
        marksman = {},
        harper_ls = {
          settings = {
            ["harper-ls"] = { userDictPath = vim.fn.stdpath("data") .. "/harper/user_dict.txt" },
          },
        },
      }
      for name, config in pairs(servers) do
        config.capabilities = capabilities
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local m = function(keys, fn, desc)
            vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
          end
          m("gd",         vim.lsp.buf.definition,   "Go to definition")
          m("K",          vim.lsp.buf.hover,         "Hover docs")
          m("<leader>ca", vim.lsp.buf.code_action,   "Code action")
          m("<leader>rn", vim.lsp.buf.rename,        "Rename")
          m("[d",         vim.diagnostic.goto_prev,  "Prev diagnostic")
          m("]d",         vim.diagnostic.goto_next,  "Next diagnostic")
          m("<leader>cd", vim.diagnostic.open_float, "Show diagnostic")
        end,
      })

      -- ── Completion ───────────────────────────────────────────────────────
      local cmp = require("cmp")
      cmp.setup({
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"]    = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]   = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = { { name = "nvim_lsp" } },
      })

      -- ── Treesitter ───────────────────────────────────────────────────────
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent    = { enable = true },
      })

      -- ── Formatting ───────────────────────────────────────────────────────
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "javascript", "json", "yaml", "markdown" },
          }),
          null_ls.builtins.formatting.shfmt,
          null_ls.builtins.formatting.terraform_fmt,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.yamllint,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("LspFormatting", { clear = true }),
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
              end,
            })
          end
        end,
      })

      -- ── NvimTree ─────────────────────────────────────────────────────────
      require("nvim-tree").setup({
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          api.config.mappings.default_on_attach(bufnr)
          local o2 = { buffer = bufnr, noremap = true, silent = true, nowait = true }
          vim.keymap.set("n", "l", api.node.open.edit,           o2)
          vim.keymap.set("n", "h", api.node.navigate.parent_close, o2)
        end,
        disable_netrw = true,
        hijack_netrw = true,
        sync_root_with_cwd = true,
        respect_buf_cwd = true,
        update_focused_file = { enable = true, update_root = true },
        view = { width = 32, side = "left" },
        renderer = { highlight_git = true, icons = { show = { git = true, folder = true, file = true } } },
        filters = { dotfiles = false },
        git = { enable = true, ignore = false },
      })

      -- ── ToggleTerm ───────────────────────────────────────────────────────
      require("toggleterm").setup({
        size = function(term)
          if term.direction == "horizontal" then return 10
          elseif term.direction == "vertical" then return vim.o.columns * 0.3
          end
        end,
        open_mapping = [[<C-t>]],
        hide_numbers = true,
        shade_terminals = true,
        start_in_insert = true,
        insert_mappings = false,
        terminal_mappings = false,
        direction = "float",
        close_on_exit = true,
        shell = vim.o.shell,
        float_opts = {
          border = "curved",
          winblend = 0,
          width = math.floor(vim.o.columns * 0.6),
          height = math.floor(vim.o.lines * 0.5),
        },
        on_open = function(term)
          term:send("cd " .. vim.fn.shellescape(vim.fn.getcwd()) .. " && clear", false)
        end,
      })
    '';
  };
}
