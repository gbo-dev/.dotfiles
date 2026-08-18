return {
  {
    -- #141617 or #0a0a0a as background_dark in
    -- .local/share/nvim/lazy/gruvbox-baby
    "luisiacc/gruvbox-baby",
    lazy = false,
    config = function()
      vim.g.gruvbox_baby_background_color = "dark"
      vim.g.gruvbox_baby_transparent_mode = 1
    end,
  },
  {
    "kyzabuilds/xeno.nvim",
    config = function()
      local xeno = require("xeno")

      -- Global defaults shared by every theme below. Each theme only needs to
      -- override background/accent (plus optional properties).
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

      -- Second syntax hues for the two-tone themes below. xeno.color() must
      -- run before any theme that references @<name>.
      xeno.color("mint", "#7cc97f")
      xeno.color("amber", "#e8b45e")
      xeno.color("cyan", "#57c7d2")
      xeno.color("plum", "#c07ac0")

      -- Every theme below is generated at startup. Switch live with:
      --   :colorscheme <name>

      -- Single-tone: one highlight color (accent) drives keywords/strings/
      -- numbers; functions/types/constants stay on the accent too.
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

      -- Contrasting: neutral dark background + a distinct accent.
      xeno.theme("ember", {
        background = "#1e1e1e",
        accent = "#e07a3f",
        contrast = 0.2,
        chroma = 0.0,
        variation = 0.1,
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

      -- Two-tone: two highlight colors in the syntax itself. The accent is
      -- tone 1 (keywords/strings/numbers); the custom color is tone 2
      -- (functions/types/constants). Named after the two highlight colors.
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
        highlights = {
          syntax = {
            ["@function"] = { fg = "@plum.200" },
            ["@type.builtin"] = { fg = "@plum.200" },
            ["@constant"] = { fg = "@plum.200" },
            ["@constant.builtin"] = { fg = "@plum.200" },
          },
        },
      })

      -- ACTIVE theme. Comment this out / pick another, or use :colorscheme <name>.
      vim.cmd("colorscheme ember")
    end,
  },
  -- {
  --   "vague-theme/vague.nvim",
  --   lazy = true,
  --   config = function()
  --     -- NOTE: you do not need to call setup if you don't want to.
  --     require("vague").setup({})
  --   end,
  -- },
  -- {
  --   "oskarnurm/koda.nvim",
  --   lazy = true,
  --   priority = 1001,
  --   config = function()
  --     require("koda").setup({ transparent = true })
  --     vim.cmd.colorscheme("koda-moss")
  --   end,
  -- },
  -- WIP local colorscheme; re-enable when ready:
  -- {
  --   dir = "/home/g/dev/ultraviolet.nvim",
  --   name = "ultraviolet.nvim",
  --   lazy = false,
  --   priority = 1000,
  -- },
}
