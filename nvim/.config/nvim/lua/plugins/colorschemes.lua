return {
  {
    -- #141617 as background_dark in
    -- .local/share/nvim/site/pack/packer/start/gruvbox-baby
    "luisiacc/gruvbox-baby",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_baby_background_color = "dark"
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    event = "User",
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    event = "User",
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    event = "User",
  },
  {
    "navarasu/onedark.nvim",
    lazy = true,
    event = "User",
  },
  {
    "marko-cerovac/material.nvim",
    lazy = true,
    event = "User",
  },
}
