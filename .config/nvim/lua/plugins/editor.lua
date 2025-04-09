return {
  "tpope/vim-fugitive",
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically
  "tpope/vim-repeat",
  "tpope/vim-rhubarb",
  "ap/vim-css-color", -- Colored background for hex 
  "nvim-lua/plenary.nvim",
  "ggandor/leap.nvim",
  "github/copilot.vim",

  { -- Keyword highlighting (TODO, NOTE etc)
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  },

  { -- gitsigns 
    "lewis6991/gitsigns.nvim",
    enabled = true,
    config = function()
      require('gitsigns').setup { -- See `:help gitsigns.txt`
	signs = {
	  add = { text = '+' },
	  change = { text = '~' },
	  delete = { text = '_' },
	  topdelete = { text = '‾' },
	  changedelete = { text = '~' },
	},
      }
    end
  },

  { -- Fuzzy finder 
    "junegunn/fzf.vim",
    dependencies = {
      "junegunn/fzf",
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
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  },

  -- {
  --   "lukas-reineke/indent-blankline.nvim",
  --   main = "ibl",
  --   ---@module "ibl"
  --   ---@type ibl.config
  --   opts = {},
  -- },

  -- {
  --   "voldikss/vim-floaterm",
  --   enabled = false
  -- },
  -- { -- Autocompletion
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "L3MON4D3/LuaSnip",
  --     "saadparwaiz1/cmp_luasnip"
  --   },
  -- },
  -- nvim-cmp supports additional completion capabilities
  -- local capabilities = vim.lsp.protocol.make_client_capabilities()
  -- capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

  -- for _, lsp in ipairs(servers) do
  --   require('lspconfig')[lsp].setup {
  --     on_attach = on_attach,
  --     capabilities = capabilities,
  --   }
  -- end

  { -- Highlight arguments of a functions
    "m-demare/hlargs.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  {
      'MeanderingProgrammer/render-markdown.nvim',
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
      -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
	dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {},
  },

  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    -- use a release tag to download pre-built binaries
    version = 'v0.*',
    opts = {
      keymap = { preset = 'default' },
      appearance = {
	use_nvim_cmp_as_default = true,
	nerd_font_variant = 'mono'
      },
      sources = {
	default = { 'lsp', 'path', 'snippets', 'buffer' },
	-- optionally disable cmdline completions
	-- cmdline = {},
      },
      -- experimental signature help support
      signature = { enabled = true }
    },
    -- allows extending the providers array elsewhere in your config
    -- without having to redefine it
    opts_extend = { "sources.default" }
  },
}
