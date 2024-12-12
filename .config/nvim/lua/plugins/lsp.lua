-- LSP Configuration & Plugins
return {

  "j-hui/fidget.nvim",

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require('mason-lspconfig').setup {
        -- Enable the following language servers
        ensure_installed = { 'clangd', 'rust_analyzer', 'pyright', 'lua_ls', 'gopls' }
      }
    end
  },

  { 
    'hrsh7th/nvim-cmp',
    dependencies = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require("mason-lspconfig").setup()
    end,
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Useful status updates for LSP
      "j-hui/fidget.nvim"
    },
  }
}
