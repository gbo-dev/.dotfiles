return {
  -- {
  --   "tpope/vim-fugitive",
  --   cmd = { "Git", "G", "Gvdiffsplit", "Gread", "Gwrite", "GBrowse" },
  -- },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    opts = {
      signs = {
        add = { text = "+", show_count = false },
        change = { text = "~", show_count = false },
        delete = { text = "_", show_count = false },
        topdelete = { text = "‾", show_count = false },
        changedelete = { text = "~", show_count = false },
        untracked = { text = "?", show_count = false },
      },
    },
  },
}
