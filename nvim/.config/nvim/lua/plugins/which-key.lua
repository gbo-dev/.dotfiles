-- Discover keymaps and contextual hints.
return {
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
}
