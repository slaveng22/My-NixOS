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
      vscode-langservers-extracted  # jsonls, html, cssls
      yaml-language-server
      marksman
      harper
      pyright
      terraform-ls
      dockerfile-language-server
      docker-compose-language-service
      typescript-language-server
      # formatters / linters
      prettier
      shfmt
      terraform
      hadolint
      yamllint
      black
      python3Packages.flake8
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
      which-key-nvim
      # Navigation
      fzf-lua
      nvim-tree-lua
      project-nvim
      # LSP + completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      # Treesitter
      (nvim-treesitter.withPlugins (p: with p; [
        bash json yaml markdown lua
        python typescript javascript html css dockerfile hcl
      ]))
      # Formatting / linting
      none-ls-nvim
      # Git
      lazygit-nvim
      # Docker
      lazydocker-nvim
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

      vim.g.neovide_cursor_animation_length = 0
      vim.g.neovide_cursor_trail_length = 0
      vim.g.neovide_cursor_antialiasing = false
      vim.g.neovide_cursor_vfx_mode = ""
      vim.o.guifont = "JetBrainsMono Nerd Font:h14"

      -- Shim for plugins still using the deprecated buf_get_clients (removed in Nvim 0.12)
      vim.lsp.buf_get_clients = function(bufnr)
        return vim.lsp.get_clients({ bufnr = bufnr or 0 })
      end

      -- ── Autocmds ─────────────────────────────────────────────────────────
      vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
          vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
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
      map("n", "<leader>fh", "<cmd>nohlsearch<cr>",  { desc = "Clear search highlight" })
      map("n", "<leader>g",  "<cmd>LazyGit<cr>",      { desc = "Open LazyGit" })
      map("n", "<leader>q", function()
        if vim.fn.confirm("Really quit?", "&Yes\n&No", 2) == 1 then vim.cmd("q!") end
      end, { desc = "Quit (!)" })
      map("n", "<leader>e",  "<cmd>NvimTreeToggle<cr>",              { desc = "Toggle explorer" })
      map("n", "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",         { desc = "Prev buffer" })
      map("n", "<S-l>",      "<cmd>BufferLineCycleNext<cr>",         { desc = "Next buffer" })
      map("n", "<leader>bd", "<cmd>bdelete<cr>",                     { desc = "Close buffer" })
      map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>",         { desc = "Pin buffer" })
      map("n", "<leader>bD", "<cmd>BufferLineGroupClose ungrouped<cr>", { desc = "Close unpinned" })
      map("t", "<C-t>",      "<cmd>ToggleTerm<cr>",                  { desc = "Toggle terminal" })
      map("n", "<leader>ff", function() require("fzf-lua").files() end,            { desc = "Find files" })
      map("n", "<leader>fg", function() require("fzf-lua").live_grep_native() end, { desc = "Live grep" })
      map("n", "<leader>fp", function()
        local projects = require("project").get_recent_projects()
        require("fzf-lua").fzf_exec(projects, {
          prompt = "Projects> ",
          actions = {
            ["default"] = function(selected)
              if selected[1] then vim.cmd("cd " .. vim.fn.fnameescape(selected[1])) end
            end,
          },
        })
      end, { desc = "Projects" })
      map("n", "<leader>d",  function() require("lazydocker").open() end, { desc = "Open LazyDocker" })
      map("n", "<leader>nc", "<cmd>NoiceDismiss<cr>", { desc = "Clear notifications" })
      map("n", "<leader>nh", "<cmd>NoiceHistory<cr>", { desc = "Notification history" })

      -- Smart save
      local function is_in_pwd_and_exists(path, pwd)
        if not path or path == "" then return false end
        local abs = vim.fn.fnamemodify(path, ":p")
        local cwd = vim.fn.fnamemodify(pwd, ":p")
        if cwd:sub(-1) ~= "/" then cwd = cwd .. "/" end
        return abs:sub(1, #cwd) == cwd and vim.fn.filereadable(abs) == 1
      end
      local function resolve_path_in_pwd(input, pwd)
        local is_abs = input:sub(1, 1) == "/" or input:sub(1, 1) == "~" or input:match("^%a:[/\\]") ~= nil
        return is_abs and input or (pwd .. "/" .. input)
      end
      local function prompt_save_into_pwd()
        local cwd = vim.fn.getcwd()
        local default = ""
        local cur = vim.api.nvim_buf_get_name(0)
        if cur ~= "" then default = vim.fn.fnamemodify(cur, ":t") end
        local input = vim.fn.input("Save as (relative to pwd: " .. cwd .. "): ", default, "file")
        if input == "" then return false end
        local path = resolve_path_in_pwd(input, cwd)
        local dir = vim.fn.fnamemodify(path, ":h")
        if dir ~= "" and vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, "p") end
        vim.cmd("saveas! " .. vim.fn.fnameescape(path))
        return true
      end
      local function smart_write()
        local bufname = vim.api.nvim_buf_get_name(0)
        if is_in_pwd_and_exists(bufname, vim.fn.getcwd()) then
          vim.cmd("write")
        else
          prompt_save_into_pwd()
        end
      end
      map("n", "<leader>w", smart_write,                                  { desc = "Write or Save As into pwd" })
      map("n", "<leader>x", function() smart_write() vim.cmd("bd") end,   { desc = "Write/Save As then quit" })

      -- ── Colorscheme ──────────────────────────────────────────────────────
      vim.g.everforest_background = "medium"
      vim.cmd.colorscheme("everforest")

      -- ── Notify ───────────────────────────────────────────────────────────
      local ok_notify, notify = pcall(require, "notify")
      if ok_notify then
        notify.setup({ max_width = 60, max_height = 8 })
        vim.notify = notify
      end

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
            cmdline     = { pattern = "^:", icon = "", lang = "vim" },
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

      -- ── Which-key ────────────────────────────────────────────────────────
      local wk = require("which-key")
      wk.setup({ preset = "helix" })
      wk.add({
        { "<leader>w",  icon = "󰆓" },
        { "<leader>x",  icon = "󰽃" },
        { "<leader>g",  icon = "󰊢" },
        { "<leader>d",  icon = "󰡨" },
        { "<leader>q",  icon = "󰩈" },
        { "<leader>e",  icon = "󰝰" },
        { "<leader>?",  icon = "󰋗" },
        { "<leader>f",  group = "Find",          icon = "󰍉" },
        { "<leader>ff", icon = "󰍉" },
        { "<leader>fg", icon = "󰈞" },
        { "<leader>fp", icon = "󰔠" },
        { "<leader>fh", icon = "󰸱" },
        { "<leader>b",  group = "Buffers",       icon = "󰈚" },
        { "<leader>c",  group = "Code",          icon = "" },
        { "<leader>n",  group = "Notifications", icon = "󰵙" },
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
        dashboard.button("o", "󰝰  Open folder", ":lua require('fzf-lua').fzf_exec('fd --type d . ' .. vim.env.HOME, { prompt = 'Folder> ', actions = { ['default'] = function(s) if s and s[1] then require('fzf-lua').files({ cwd = s[1] }) end end } })<CR>"),
        dashboard.button("g", "󰈞  Live grep",   ":lua require('fzf-lua').live_grep_native()<CR>"),
        dashboard.button("p", "󰔠  Projects",    ":lua local p=require('project').get_recent_projects(); require('fzf-lua').fzf_exec(p,{prompt='Projects> ',actions={['default']=function(s) if s[1] then vim.cmd('cd '..vim.fn.fnameescape(s[1])) end end}})<CR>"),
        dashboard.button("q", "󰩈  Quit",        ":qa<CR>"),
      }
      require("project").setup({
        use_lsp = false,
        patterns = { ".git" },
        show_hidden = false,
        silent_chdir = true,
      })
      alpha.setup(dashboard.config)

      -- ── FZF-lua ──────────────────────────────────────────────────────────
      require("fzf-lua").setup({})

      -- ── Comment ──────────────────────────────────────────────────────────
      require("Comment").setup({})

      -- ── LSP ──────────────────────────────────────────────────────────────
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      local servers = {
        lua_ls    = { settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
        bashls    = {},
        jsonls    = {},
        yamlls    = {},
        dockerls  = {},
        docker_compose_language_service = {},
        terraformls = {},
        pyright   = {},
        html      = {},
        cssls     = {},
        ts_ls     = {},
        marksman  = {},
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
          m("<leader>cr", vim.lsp.buf.rename,        "Rename symbol")
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
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer", keyword_length = 3 },
          { name = "path" },
        },
      })

      -- ── Treesitter ───────────────────────────────────────────────────────
      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent    = { enable = true },
      })

      -- ── Formatting ───────────────────────────────────────────────────────
      local null_ls = require("null-ls")
      local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.prettier.with({
            filetypes = { "html", "css", "javascript", "json", "yaml", "markdown" },
          }),
          null_ls.builtins.formatting.shfmt,
          null_ls.builtins.formatting.terraform_fmt,
          null_ls.builtins.diagnostics.hadolint,
          null_ls.builtins.diagnostics.yamllint,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = lsp_fmt_group, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = lsp_fmt_group,
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
          vim.keymap.set("n", "l", api.node.open.edit,             o2)
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

      -- ── LazyDocker ───────────────────────────────────────────────────────
      require("lazydocker").setup({ floating_window = true })

      -- ── Cheatsheet ───────────────────────────────────────────────────────
      local cheatsheet = (function()
        local M = {}
        M.entries = {
          { title = "Quote word", body = [[
1. ciw'<ESC>p - Quote with single quotes
2. ciw"<ESC>p - Quote with double quotes

  ciw  → delete inner word (stored in register)
  "    → type opening quote
  <ESC>→ exit insert mode
  p    → paste deleted word after cursor]] },
          { title = "Unquote word (remove surrounding quotes)", body = [[
di'va'p   — for single quotes
di"va"p   — for double quotes

  di'  → delete inside single quotes (word into register)
  va'  → select around single quotes (including quotes)
  p    → paste word over selection (replaces quotes + word)]] },
          { title = "Project-wide find & replace", body = [[
1. <leader>fg  — live grep
2. Find the text, press CTRL+q  → send to quickfix
3. Run: :cfdo %s/old/new/gc | update

  :cfdo          → run on every quickfix file
  %s/old/new/gc  → replace with confirmation
  | update       → save each file]] },
          { title = "Increment/decrement numbers in visual block", body = [[
1. CTRL+v  — visual block mode
2. Select column of numbers
3. g CTRL+a  — increment sequentially (1,2,3...)
   g CTRL+x  — decrement sequentially

  CTRL+a/x alone → same value for all lines
  g CTRL+a/x     → sequential increment/decrement]] },
          { title = "Run macro on visual selection", body = [[
1. Record macro: qa ... q  (record into register a)
2. Select lines in visual mode
3. :'<,'>normal @a

  :'<,'>      → range of visual selection
  normal @a   → run macro 'a' on each line]] },
          { title = "Sort and remove duplicate lines", body = [[
Visual select lines, then:
  :'<,'>sort u

Or entire file:
  :%sort u

  sort   → alphabetically sort
  u flag → remove duplicates]] },
          { title = "Align text on a character", body = [[
Visual select lines, then:
  :'<,'>!column -t -s '=' -o '='

Aligns on '=' character (change as needed)

  column -t  → create table
  -s '='     → split on '='
  -o '='     → output separator '=']] },
          { title = "Swap two words", body = [[
Place cursor on first word:
  dawwP

  daw  → delete a word (into register)
  w    → move to next word
  P    → paste before cursor (swaps positions)]] },
          { title = "Join lines with custom separator", body = [[
Visual select lines, then:
  :s/\n/, /g

Joins with ', ' — change separator as needed

Or join without spaces:
  :s/\n//g]] },
          { title = "Edit remote files", body = [[
nvim scp://user@host//absolute/path/to/file
nvim scp://user@host/relative/to/home

Browse remote directory:
  nvim scp://user@host/

Tip: add host to ~/.ssh/config for short names:
  Host myserver
    HostName 192.168.1.10
    User slaven

  Then: nvim scp://myserver//etc/nginx/nginx.conf

All local plugins (LSP, formatting, etc.) work normally.]] },
        }
        function M.open()
          local fzf = require("fzf-lua")
          local titles = {}
          for i, e in ipairs(M.entries) do titles[i] = i .. ". " .. e.title end
          fzf.fzf_exec(titles, {
            prompt = "Cheatsheet> ",
            actions = {
              ["default"] = function(selected)
                if not selected or not selected[1] then return end
                local idx = tonumber(selected[1]:match("^(%d+)%."))
                local lines = vim.split(M.entries[idx].body, "\n")
                local buf = vim.api.nvim_create_buf(false, true)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
                local width = 0
                for _, l in ipairs(lines) do width = math.max(width, #l) end
                vim.api.nvim_open_win(buf, true, {
                  relative = "editor",
                  width = math.min(width + 2, vim.o.columns - 4),
                  height = #lines,
                  row = math.floor((vim.o.lines - #lines) / 2),
                  col = math.floor((vim.o.columns - width) / 2),
                  style = "minimal", border = "rounded",
                  title = " " .. M.entries[idx].title .. " ", title_pos = "center",
                })
                vim.keymap.set("n", "q",     "<cmd>close<cr>", { buffer = buf, silent = true })
                vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
              end,
            },
          })
        end
        return M
      end)()
      map("n", "<leader>?", function() cheatsheet.open() end, { desc = "Cheatsheet" })

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
