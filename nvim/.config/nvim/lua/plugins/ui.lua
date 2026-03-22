return {
  { -- Keyword highlighting (TODO, NOTE etc)
    "folke/todo-comments.nvim",
    event = "VeryLazy",
    dependencies = "nvim-lua/plenary.nvim",
    opts = { signs = false },
  },

  { -- Pretty list for diagnostics, LSP stuff and errors
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    cmd = "Trouble",
    opts = {},
  },

  { -- Fancier statusline
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
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
