return {
  -- Useful status updates for LSP
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

  -- Mason: auto-install LSP servers and tools
  {
    "mason-org/mason.nvim",
    lazy = false,
    cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonLog", "MasonUpdate" },
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    opts = {
      ensure_installed = { "clangd", "rust_analyzer", "lua_ls", "gopls", "zls" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Merge blink.cmp capabilities into all LSP clients
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      -- LspAttach: buffer-local keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("gra", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint", event.buf) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- lua_ls: Neovim config needs special runtime/library settings
      -- (lspconfig default doesn't ship the on_init logic)
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

      -- gopls: only non-default settings
      -- lspconfig default: cmd, filetypes, root_dir
      -- gopls default: semanticTokens=false, hoverKind=FullDocumentation,
      --   linkTarget=pkg.go.dev, completeUnimported=true, most analyses enabled
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

      vim.lsp.enable({ "clangd", "rust_analyzer", "lua_ls", "gopls", "zls" })
    end,
  },
}
