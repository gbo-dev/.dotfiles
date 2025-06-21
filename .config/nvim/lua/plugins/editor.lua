return {
  "tpope/vim-sleuth",      -- Detect tabstop and shiftwidth automatically
  "tpope/vim-repeat",
  "nvim-lua/plenary.nvim", -- Explicit dependency, or let others pull it in
  "ggandor/leap.nvim",
  "github/copilot.vim",

  { -- Fuzzy finder
    "junegunn/fzf.vim",
    dependencies = {
      "junegunn/fzf",
      build = function()
        vim.cmd([[call fzf#install()]])
      end,
    }
  },

  {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
  },

  {
    'saghen/blink.cmp',
    dependencies = 'rafamadriz/friendly-snippets',
    version = 'v0.*',
    opts = {
      keymap = { preset = 'default' },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      signature = { enabled = true }
    },
    opts_extend = { "sources.default" }
  },

  {
    "echasnovski/mini.move",
    enabled = true,
    config = function()
      require('mini.move').setup {
        mappings = {
          left = '<M-Left>',
          right = '<M-Right>',
          down = '<M-Down>',
          up = '<M-Up>',
          line_left = '<M-Left>',
          line_right = '<M-Right>',
          line_down = '<M-Down>',
          line_up = '<M-Up>',
        },
        options = {
          reindent_linewise = true,
        },
      }
    end
  },
}
