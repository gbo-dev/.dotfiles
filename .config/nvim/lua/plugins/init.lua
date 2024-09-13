return {
  {
    'j-hui/fidget.nvim',
    tag = 'legacy'
  },
  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim'
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    }
  },

  {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "neovim/nvim-lspconfig",
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup()
    end,
  },

  {
    "nvim-lua/plenary.nvim",
  },

  { -- Keyword highlighting (TODO, NOTE etc)
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  },

  { -- Fuzzy finder 
    'junegunn/fzf.vim',
    dependencies = {
      'junegunn/fzf',
      build = function()
	vim.cmd([[call fzf#install()]])
      end,
    }
  },

  { -- Pretty list for diagnostics, LSP stuff and errors 
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  },

  {
    'windwp/nvim-autopairs',
    config = function() require("nvim-autopairs").setup {} end
  },

  'luisiacc/gruvbox-baby', -- NOTE: #141617 as background_dark in .local/share/nvim/site/pack/packer/start/gruvbox-baby
  'arturgoms/moonbow.nvim',
  'voldikss/vim-floaterm',
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'lewis6991/gitsigns.nvim',
  'navarasu/onedark.nvim', -- Theme inspired by Atom
  'ap/vim-css-color', -- Colored background for hex 
  'nvim-lualine/lualine.nvim', -- Fancier statusline
  'lukas-reineke/indent-blankline.nvim', -- Add indentation guides even on blank line
  'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'tpope/vim-repeat',
  'lewis6991/impatient.nvim',
  'ggandor/leap.nvim',
  'echasnovski/mini.move',

  { -- Highlight arguments of a functions
    'm-demare/hlargs.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('hlargs').setup()
    end,
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  { -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = vim.fn.executable 'make' == 1
  },


  {  -- Directory structure/tree
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons'},
    tag = 'nightly'
  },
  {
    "catppuccin/nvim", 
    name = "catppuccin",
    priority = 1000
  },

  {
    'github/copilot.vim'
  },

  {
    'navarasu/onedark.nvim'
  },

  
}
