return {
  { -- Keyword highlighting (TODO, NOTE etc)
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup {}
    end
  },
  { -- Pretty list for diagnostics, LSP stuff and errors
    "folke/trouble.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  },
  { -- Fancier statusline
    "nvim-lualine/lualine.nvim",
    config = function()
      -- Build a theme derived from your current colorscheme if available.
      -- Then make only the bar's filler background (between segments) transparent
      local function build_theme()
        local cs = vim.g.colors_name or ''
        local ok, cs_theme = pcall(require, 'lualine.themes.' .. cs)
        local theme = ok and cs_theme or require('lualine.themes.auto')
        local modes = { 'normal', 'insert', 'visual', 'replace', 'command', 'inactive' }
        for _, m in ipairs(modes) do
          if theme[m] then
            -- Make inner segments transparent
            if theme[m].b then theme[m].b.bg = 'none' end
            if theme[m].c then theme[m].c.bg = 'none' end
            if theme[m].x then theme[m].x.bg = 'none' end
            if theme[m].y then theme[m].y.bg = 'none' end
          end
        end
        return theme
      end

      local function setup_lualine()
        require("lualine").setup {
          options = {
            icons_enabled = false,
            theme = build_theme(), -- keep segment colors; transparent filler
            component_separators = " ",
            section_separators = "",
          },
          sections = {
            lualine_c = {
              {
                'filename',
                path = 1, -- 0: just filename, 1: relative path, 2: absolute path
              }
            }
          }
        }
      end

      setup_lualine()
      -- Reapply when colorscheme changes so segment colors stay correct.
      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = setup_lualine,
        group = vim.api.nvim_create_augroup('LualineRefreshOnColorScheme', { clear = true }),
      })
    end
  }
}
