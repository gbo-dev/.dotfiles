-- Statusline themed from the active colorscheme.
return {
  "nvim-lualine/lualine.nvim",
  event = "VimEnter",
  config = function()
    local function build_theme()
      local cs = vim.g.colors_name or ""
      local ok, cs_theme = pcall(require, "lualine.themes." .. cs)
      local theme = ok and cs_theme or require("lualine.themes.auto")
      -- Keep the mode indicator colored while making the rest of the bar transparent.
      local modes = { "normal", "insert", "visual", "replace", "command", "inactive", "terminal" }
      local transparent_sections = { "b", "c", "x", "y" }
      for _, mode in ipairs(modes) do
        for _, section in ipairs(transparent_sections) do
          if theme[mode] and theme[mode][section] then
            theme[mode][section].bg = "none"
          end
        end
      end
      return theme
    end

    local function clear_statusline_background()
      -- Lualine groups without an explicit background inherit StatusLine's.
      for _, group in ipairs({ "StatusLine", "StatusLineNC" }) do
        vim.api.nvim_set_hl(0, group, {
          bg = "NONE",
          ctermbg = "NONE",
          update = true,
        })
      end
    end

    local function setup_lualine()
      require("lualine").setup({
        options = {
          icons_enabled = false,
          theme = build_theme(),
          component_separators = " ",
          section_separators = "",
        },
        sections = {
          lualine_c = {
            {
              "filename",
              path = 1,
            },
          },
        },
      })
      clear_statusline_background()
    end

    setup_lualine()
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = setup_lualine,
      group = vim.api.nvim_create_augroup("LualineRefreshOnColorScheme", { clear = true }),
    })
  end,
}
