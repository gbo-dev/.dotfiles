-- Move lines and selections.
return {
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
}
