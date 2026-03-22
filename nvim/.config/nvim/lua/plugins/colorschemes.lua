return {
  {
    -- #141617 or #0a0a0a as background_dark in
    -- .local/share/nvim/lazy/gruvbox-baby
    "luisiacc/gruvbox-baby",
    lazy = false,
    config = function()
      vim.g.gruvbox_baby_background_color = "dark"
      vim.g.gruvbox_baby_transparent_mode = 1
      vim.cmd.colorscheme("gruvbox-baby")
    end,
  },
  {
    "vague-theme/vague.nvim",
    lazy = true,
    config = function()
      -- NOTE: you do not need to call setup if you don't want to.
      require("vague").setup({})
    end,
  },
  {
    "oskarnurm/koda.nvim",
    lazy = true,
    priority = 1001,
    config = function()
      require("koda").setup({ transparent = true })
      vim.cmd.colorscheme("koda-moss")
    end,
  },
}
