return {
  "tpope/vim-sleuth", -- Auto-detect indent style
  "tpope/vim-repeat", -- Dot-repeat for plugin maps

  {
    url = "https://codeberg.org/andyg/leap.nvim",
  },

  "github/copilot.vim",

  -- fzf: currently unused (using Snacks picker instead)
  -- {
  --   "junegunn/fzf.vim",
  --   dependencies = {
  --     "junegunn/fzf",
  --     build = function()
  --       vim.cmd([[call fzf#install()]])
  --     end,
  --   },
  -- },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    event = "VimEnter",
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },

  {
    "echasnovski/mini.move",
    event = "VeryLazy",
    opts = {
      mappings = {
        left = "<M-Left>",
        right = "<M-Right>",
        down = "<M-Down>",
        up = "<M-Up>",
        line_left = "<M-Left>",
        line_right = "<M-Right>",
        line_down = "<M-Down>",
        line_up = "<M-Up>",
      },
      options = {
        reindent_linewise = true,
      },
    },
  },

  { -- Better Around/Inside textobjects
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 500 },
  },

  { -- Add/delete/replace surroundings (brackets, quotes, etc.)
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },

  {
    "folke/which-key.nvim",
    event = "VimEnter",
    ---@module 'which-key'
    ---@type wk.Opts
    opts = {
      delay = 0,
      preset = "helix",
      icons = { mappings = true },
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
        presets = {
          operators = true,
          motions = true,
          text_objects = true,
          windows = true,
          nav = true,
          z = true,
          g = true,
        },
      },
      spec = {
        { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>x", group = "Trouble" },
        { "<leader>g", group = "[G]it" },
        { "<leader>f", group = "[F]ind" },
        { "<leader>w", group = "[W]orkspace" },
        { "gr", group = "LSP Actions", mode = { "n" } },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
}
