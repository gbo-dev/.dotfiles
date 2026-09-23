return {
  -- #141617 or #0a0a0a as background_dark in
  -- .local/share/nvim/lazy/gruvbox-baby
  "luisiacc/gruvbox-baby",
  lazy = false,
  config = function()
    vim.g.gruvbox_baby_background_color = "dark"
    vim.g.gruvbox_baby_transparent_mode = 1
  end,
}
