return {
  { "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } }, -- Detect tabstop and shiftwidth automatically
  "tpope/vim-repeat", -- Dot-repeat for plugin maps
  "nvim-lua/plenary.nvim", -- Utility library (used by various plugins and scripts)
  { -- leap.nvim
    url = "https://codeberg.org/andyg/leap.nvim",
    keys = {
      { "<Leader>ss", "<Plug>(leap-forward)", desc = "Leap forward" },
      { "<Leader>SS", "<Plug>(leap-backward)", desc = "Leap backward" },
    },
  },
  { -- blink.cmp
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    event = "InsertEnter",
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "default" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        menu = { border = "single" },
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      signature = { enabled = true },
    },
    opts_extend = { "sources.default" },
  },
  { -- mini.ai: Better Around/Inside textobjects
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    --  - ci'  - [C]hange [I]nside [']quote
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = { n_lines = 500 },
  },
  { -- mini.move
    "nvim-mini/mini.move",
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
  { "nvim-mini/mini.pairs", version = "*" },
  { -- mini.surround: Add/delete/replace surroundings (brackets, quotes, etc.)
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    "nvim-mini/mini.surround",
    event = "VeryLazy",
    opts = {},
  },
  { -- which-key.nvim
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
}
