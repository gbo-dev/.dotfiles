vim.loader.enable()

require("config.options")
require("config.lazy")
require("config.autocmd")
require("config.lsp-diagnostics")
require("config.keymap")

-- vim.cmd([[colorscheme gruvbox-baby]])
-- vim.cmd([[colorscheme vague]])
vim.cmd([[colorscheme koda-moss]])

-- Consistent background (#0a0a0a) and transparent statusline
vim.cmd([[
  highlight Normal guibg=#0a0a0a
  highlight NormalFloat guibg=#0a0a0a
  highlight StatusLine guibg=#0a0a0a
  highlight StatusLineNC guibg=#0a0a0a
]])
