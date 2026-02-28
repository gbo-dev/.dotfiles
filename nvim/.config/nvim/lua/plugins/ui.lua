return {
  { -- Keyword highlighting (TODO, NOTE etc)
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = "nvim-lua/plenary.nvim",
    opts = { signs = false },
  },

  { -- Pretty list for diagnostics, LSP stuff and errors
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    cmd = "Trouble",
    opts = {},
  },

  { -- Autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[C]ode [F]ormat buffer",
      },
      {
        "<leader>df",
        function()
          vim.b.disable_autoformat = not vim.b.disable_autoformat
          local state = vim.b.disable_autoformat and "disabled" or "enabled"
          vim.notify("Format-on-save " .. state .. " for this buffer")
        end,
        desc = "[D]isable [F]ormat-on-save (buffer)",
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Per-buffer disable via <leader>df
        if vim.b[bufnr].disable_autoformat then
          return nil
        end
        -- Disable format_on_save for languages without a standardized style
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        -- go = { "gofmt" },  -- gopls handles this via LSP fallback
        -- python = { "isort", "black" },
        javascript = { "biome" },
        typescript = { "biome" },
        javascriptreact = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
      },
    },
  },

  { -- Fancier statusline
    "nvim-lualine/lualine.nvim",
    config = function()
      local function build_theme()
        local cs = vim.g.colors_name or ""
        local ok, cs_theme = pcall(require, "lualine.themes." .. cs)
        local theme = ok and cs_theme or require("lualine.themes.auto")
        local modes = { "normal", "insert", "visual", "replace", "command", "inactive" }
        for _, m in ipairs(modes) do
          if theme[m] then
            if theme[m].b then
              theme[m].b.bg = "none"
            end
            if theme[m].c then
              theme[m].c.bg = "none"
            end
            if theme[m].x then
              theme[m].x.bg = "none"
            end
            if theme[m].y then
              theme[m].y.bg = "none"
            end
          end
        end
        return theme
      end

      local function setup_lualine()
        require("lualine").setup({
          options = {
            icons_enabled = false,
            theme = build_theme(),
            component_separators = " ",
            section_separators = "",
          },
          sections = {
            lualine_c = {
              {
                "filename",
                path = 1, -- relative path
              },
            },
          },
        })
      end

      setup_lualine()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = setup_lualine,
        group = vim.api.nvim_create_augroup("LualineRefreshOnColorScheme", { clear = true }),
      })
    end,
  },
}
