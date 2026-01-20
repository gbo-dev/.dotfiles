return {
  {
    "j-hui/fidget.nvim"
  },

  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
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
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      local lspconfig = require("lspconfig")

      -- Setup mason-lspconfig first
      require("mason-lspconfig").setup({
      --'clangd', 'rust_analyzer', 'pyright', 'lua_ls', 'gopls' 
        ensure_installed = { 'clangd', 'rust_analyzer', 'lua_ls', 'gopls' },
        handlers = {
          -- Default handler for most servers
          function(server_name)
            lspconfig[server_name].setup {
              capabilities = capabilities,
            }
          end,

          -- Special handler for lua_ls
          ["lua_ls"] = function()
            lspconfig.lua_ls.setup {
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = {
                    version = 'LuaJIT',
                  },
                  diagnostics = {
                    globals = { 'vim' },
                  },
                  workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                  },
                  telemetry = {
                    enable = false,
                  },
                },
              },
            }
          end,
        },
      })
    end,
  },
}
