return {
  -- Useful status updates for LSP
  { "j-hui/fidget.nvim", opts = {} },

  -- Mason: auto-install LSP servers and tools
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "clangd", "rust_analyzer", "lua_ls", "gopls", "zls" },
    },
  },

  -- Mason tool installer: ensures formatters/linters are installed too
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "stylua", -- lua formatter
        "biome",  -- js/ts/json formatter
      },
    },
  },

  -- Allows extra capabilities provided by blink.cmp
  "saghen/blink.cmp",

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- LspAttach: buffer-local keymaps and features when an LSP connects
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Uses gr-prefix convention (Neovim 0.11+ standard)
          map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("gra", vim.lsp.buf.code_action, "Code [A]ction", { "n", "x" })
          map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Toggle inlay hints if supported
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint", event.buf) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      -- Server configurations using vim.lsp.config() + vim.lsp.enable()
      -- Capabilities from blink.cmp are merged automatically via vim.lsp.config('*', ...)
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      -- lua_ls: Neovim Lua development
      vim.lsp.config("lua_ls", {
        on_init = function(client)
          -- Only apply Neovim-specific settings when editing nvim config
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
            runtime = {
              version = "LuaJIT",
              path = { "lua/?.lua", "lua/?/init.lua" },
            },
            workspace = {
              checkThirdParty = false,
              library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
                "${3rd}/luv/library",
                "${3rd}/busted/library",
              }),
            },
          })
        end,
        settings = {
          Lua = {},
        },
      })

      -- gopls: Go development
      local util = require("lspconfig.util")
      vim.lsp.config("gopls", {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl" },
        root_dir = util.root_pattern("go.work", "go.mod", ".git"),
        settings = {
          gopls = {
            analyses = {
              assign = true,
              atomic = true,
              bools = true,
              composites = true,
              copylocks = true,
              deepequalerrors = true,
              embed = true,
              errorsas = true,
              fieldalignment = true,
              httpresponse = true,
              ifaceassert = true,
              loopclosure = true,
              lostcancel = true,
              nilfunc = true,
              nilness = true,
              nonewvars = true,
              printf = true,
              shadow = true,
              shift = true,
              simplifycompositelit = true,
              simplifyrange = true,
              simplifyslice = true,
              sortslice = true,
              stdmethods = true,
              stringintconv = true,
              structtag = true,
              testinggoroutine = true,
              tests = true,
              timeformat = true,
              unmarshal = true,
              unreachable = true,
              unsafeptr = true,
              unusedparams = true,
              unusedresult = true,
              unusedvariable = true,
              unusedwrite = true,
              useany = true,
            },
            hoverKind = "FullDocumentation",
            linkTarget = "pkg.go.dev",
            usePlaceholders = true,
            vulncheck = "Imports",
          },
        },
      })

      -- Enable all configured servers
      vim.lsp.enable({ "lua_ls", "gopls", "clangd", "rust_analyzer", "zls" })
    end,
  },
}
