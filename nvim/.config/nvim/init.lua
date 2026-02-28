vim.loader.enable()

require("config.options")
require("config.lazy")
require("config.autocmd")
require("config.lsp-diagnostics")
require("config.keymap")

vim.cmd([[colorscheme gruvbox-baby]])
-- vim.cmd([[colorscheme kanagawa]])

-- Transparent statusline background (defers to terminal bg)
vim.cmd([[
  highlight StatusLine guibg=none
  highlight StatusLineNC guibg=none
]])
