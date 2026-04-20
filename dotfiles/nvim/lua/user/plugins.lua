local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Theme
    {
        "ellisonleao/gruvbox.nvim",
        priority = 1000,
        config = function() vim.cmd("colorscheme gruvbox") end,
    },

    -- Dashboard
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "██████   █████                   █████   █████  ███                 ",
                "░░██████ ░░███                   ░░███   ░░███  ░░░                  ",
                " ░███░███ ░███   ██████   ██████  ░███    ░███  ████  █████████████  ",
                " ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ░░███░░███░░███ ",
                " ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███  ░███ ░███ ░███ ",
                " ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███  ░███ ░███ ░███ ",
                " █████  ░░█████░░██████ ░░██████     ░░███      █████ █████░███ █████",
            }

            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file", ":ene <BAR> startinsert<CR>"),
                dashboard.button("f", "  Find file", ":lua require('telescope.builtin').find_files()<CR>"),
                dashboard.button("g", "󰈞  Live grep", ":lua require('telescope.builtin').live_grep()<CR>"),
                dashboard.button("l", "󰒲  Manage plugins (Lazy)", ":Lazy<CR>"),
                dashboard.button("q", "󰩈  Quit", ":qa<CR>"),
            }

            alpha.setup(dashboard.config)
        end,
    },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = { theme = "gruvbox", section_separators = "", component_separators = "" }
            })
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({})
            local builtin = require("telescope.builtin")

            vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
            vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
            vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
        end,
    },

    -- Command popup
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("noice").setup({
                cmdline = {
                    enabled = true,
                    view = "cmdline_popup",
                    format = {
                        cmdline = { pattern = "^:", icon = "", title = "Command" },
                        search_down = { kind = "search", icon = "", title = "Search ↓" },
                        search_up   = { kind = "search", icon = "", title = "Search ↑" },
                    },
                },
                messages = { enabled = true, view = "mini" },
                popupmenu = { enabled = true, backend = "nui" },
                presets = { bottom_search = false, command_palette = true },
            })
        end,
    },

    -- Bufferline
    {
        "akinsho/bufferline.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require("bufferline").setup({
                options = {
                    diagnostics = "nvim_lsp",
                    numbers = "none",
                    show_buffer_close_icons = true,
                    show_close_icon = false,
                    separator_style = "slant",
                    always_show_bufferline = true,
                }
            })
        end,
    },

    -- ToggleTerm + LazyGit
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        config = function()
            local toggleterm = require("toggleterm")
            toggleterm.setup({
                size = 20,
                open_mapping = false,
                direction = "float",
                close_on_exit = true,
                shell = vim.o.shell,
            })

            local Terminal = require("toggleterm.terminal").Terminal
            local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

            function _lazygit_toggle()
                lazygit:toggle()
            end

            vim.keymap.set("n", "<leader>gg", _lazygit_toggle, { desc = "Open LazyGit" })
        end,
    },
})
