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
      require("lualine").setup {
        options = {
          icons_enabled = false,
          --theme = "onedark",
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
  }
}
