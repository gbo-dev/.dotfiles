return {
  {
    -- #141617 as background_dark in
    -- .local/share/nvim/site/pack/packer/start/gruvbox-baby
    "luisiacc/gruvbox-baby",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_baby_background_color = "dark"
      vim.g.gruvbox_baby_transparent_mode = 1
    end,
  },
  {
    "rebelot/kanagawa.nvim",
    -- lazy = true,
    event = "User",
    transparent = true,
    dimInactive = false,
    opts = {
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none"
            }
          }
        }
      }
    },
  },
}
