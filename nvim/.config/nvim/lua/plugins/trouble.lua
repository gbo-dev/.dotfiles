-- Diagnostics, quickfix, and loclist views.
return {
  "folke/trouble.nvim",
  dependencies = "nvim-tree/nvim-web-devicons",
  cmd = "Trouble",
  keys = {
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle<cr>",
      desc = "Trouble: diagnostics",
    },
    {
      "<leader>xd",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Trouble: buffer diagnostics",
    },
    {
      "<leader>xq",
      "<cmd>Trouble qflist toggle<cr>",
      desc = "Trouble: quickfix",
    },
    {
      "<leader>xl",
      "<cmd>Trouble loclist toggle<cr>",
      desc = "Trouble: loclist",
    },
  },
  opts = {},
}
