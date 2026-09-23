return {
  "kyzabuilds/xeno.nvim",
  enabled = false,
  config = function()
    local xeno = require("xeno")

    xeno.setup({
      background = "#1E1E1E",
      accent = "#8CBE8C",
      highlights = {
        editor = {
          CursorLine = { bg = "@background.700" },
          CursorLineNr = { fg = "@foreground.50" },
        },
      },
      integrations = {
        ghostty = {
          enabled = false,
          update_config = false,
        },
      },
    })

    xeno.color("mint", "#7cc97f")
    xeno.color("amber", "#e8b45e")
    xeno.color("cyan", "#57c7d2")
    xeno.color("plum", "#c07ac0")

    xeno.theme("sylvan", {
      background = "#141615",
      accent = "#4a7a5c",
      contrast = 0.2,
      variation = 0.1,
      chroma = 0.1,
    })
    xeno.theme("emerald", {
      background = "#15241f",
      accent = "#4cd48a",
      variation = 0.5,
      chroma = 0.1,
      contrast = 0.2,
    })
    xeno.theme("sapphire", {
      background = "#141c2c",
      accent = "#5ba0e8",
      variation = 0.6,
      lightness = -0.1,
      chroma = 0.3,
      contrast = 0.2,
    })
    xeno.theme("violet", {
      background = "#1e1e1e",
      accent = "#c0a6f7",
      contrast = 0.3,
    })
    xeno.theme("rose", {
      background = "#1e1e1e",
      accent = "#f08a9a",
      contrast = 0.3,
    })
    xeno.theme("midnight", {
      background = "#161a2b",
      accent = "#e8b45e",
      contrast = 0.3,
      chroma = 0.1,
      variation = 0.1,
    })
    xeno.theme("teal-mint", {
      background = "#122b29",
      accent = "#5fb3a1",
      contrast = 0.3,
      chroma = 0.1,
      variation = 0.1,
      highlights = {
        syntax = {
          ["@function"] = { fg = "@mint.200" },
          ["@type.builtin"] = { fg = "@mint.200" },
          ["@constant"] = { fg = "@mint.200" },
          ["@constant.builtin"] = { fg = "@mint.200" },
        },
      },
    })
    xeno.theme("cyan-amber", {
      background = "#162a2e",
      accent = "#57c7d2",
      contrast = 0.3,
      chroma = 0.1,
      variation = 0.1,
      highlights = {
        syntax = {
          ["@function"] = { fg = "@amber.200" },
          ["@type.builtin"] = { fg = "@amber.200" },
          ["@constant"] = { fg = "@amber.200" },
          ["@constant.builtin"] = { fg = "@amber.200" },
        },
      },
    })
    xeno.theme("rose-plum", {
      background = "#2a1a24",
      accent = "#f08a9a",
      contrast = 0.3,
      chroma = 0.1,
      variation = 0.1,
      highlights = {
        syntax = {
          ["@function"] = { fg = "@plum.200" },
          ["@type.builtin"] = { fg = "@plum.200" },
          ["@constant"] = { fg = "@plum.200" },
          ["@constant.builtin"] = { fg = "@plum.200" },
        },
      },
    })

  end,
}
