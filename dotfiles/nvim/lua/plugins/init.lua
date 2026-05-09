require("lazy").setup({

  -- Colorscheme
  {
    "sainnhe/everforest",
    priority = 1000,
    config = function()
      require("plugins.ui").colorscheme()
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.ui").lualine()
    end,
  },

  -- Bufferline (tabs)
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.bufferline")
    end,
  },

  -- Noice (UI messages / cmdline)
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("plugins.ui").noice()
    end,
  },

  -- Dashboard
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.dashboard")
    end,
  },

  -- Project management (recent git repos)
  {
    "ahmedkhalf/project.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- setup is called inside plugins/dashboard.lua
      require("telescope").load_extension("projects")
    end,
  },

  -- Telescope (required by project.nvim picker)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- FZF
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.fzf")
    end,
  },

  -- LazyGit
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.git")
    end,
  },

  -- Comments
  {
    "numToStr/Comment.nvim",
    opts = {},
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("plugins.lsp")
    end,
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      require("plugins.cmp")
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("plugins.treesitter")
    end,
  },
  -- Formating
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("plugins.formatting")
    end,
  },

  -- File manager
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("plugins.nvimtree")
    end,
  },

  -- Toggletermnal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("plugins.toggleterm")
    end,
  },


}, {
  change_detection = { enabled = true, notify = false },
})

