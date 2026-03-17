return {
  {
    -- #141617 or #0a0a0a as background_dark in
    -- .local/share/nvim/lazy/gruvbox-baby
    "luisiacc/gruvbox-baby",
    lazy = true,
    config = function()
      vim.g.gruvbox_baby_background_color = "dark"
      vim.g.gruvbox_baby_transparent_mode = 1
    end,
  },
  {
    "vague-theme/vague.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1001, -- make sure to load this before all the other plugins
    config = function()
      -- NOTE: you do not need to call setup if you don't want to.
      require("vague").setup({})
    end,
  },
  {
    "oskarnurm/koda.nvim",
    lazy = true, -- make sure we load this during startup if it is your main colorscheme
    config = function()
      require("koda").setup({ transparent = true })
    end,
  },
}
