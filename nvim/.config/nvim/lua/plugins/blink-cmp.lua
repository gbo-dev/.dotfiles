return {
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
}
