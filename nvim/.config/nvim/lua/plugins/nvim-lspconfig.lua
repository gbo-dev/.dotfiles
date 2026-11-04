return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "j-hui/fidget.nvim",
    "saghen/blink.cmp",
  },
  config = function()
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })

    vim.lsp.config("lua_ls", {
      on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
            path ~= vim.fn.stdpath("config")
            and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
          then
            return
          end
        end
        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
          workspace = {
            checkThirdParty = false,
            library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
              "${3rd}/luv/library",
              "${3rd}/busted/library",
            }),
          },
        })
      end,
      settings = { Lua = {} },
    })

    vim.lsp.config("gopls", {
      capabilities = vim.tbl_deep_extend("force", capabilities, { semanticTokensProvider = false }),
      settings = {
        gopls = {
          gofumpt = true,
          staticcheck = true,
          vulncheck = "Imports",
          usePlaceholders = true,
          analyses = {
            shadow = true,
            unusedparams = true,
            unusedvariable = true,
            unusedwrite = true,
            useany = true,
          },
        },
      },
    })

    vim.lsp.enable({ "clangd", "rust_analyzer", "lua_ls", "gopls", "zls", "oxlint" })
  end,
}
