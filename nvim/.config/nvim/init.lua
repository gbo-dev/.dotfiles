-- TODO:
-- Add mini.comment perhaps Add vim-surround? Hmm
-- Add normal mode insert space and newline insertion without switching modes

vim.loader.enable()

require("config.options")
require("config.lazy")
require("config.autocmd")
require("config.lsp-diagnostics")
require("config.keymap")

require("plugins.colorschemes")
require("plugins.editor")
require("plugins.lsp")
require("plugins.treesitter")
require("plugins.snacks")
require("plugins.git")
require("plugins.ui")

vim.cmd [[colorscheme gruvbox-baby]]
-- vim.cmd [[colorscheme kanagawa]]

-- NOTE: Test
-- transparent theme backgrounds + UI elements 
-- Instead depends on terminal background
vim.cmd [[
  "highlight Normal guibg=none
  "highlight NonText guibg=none
  "highlight Normal ctermbg=none
  "highlight NonText ctermbg=none
  "highlight SignColumn guibg=none
  "highlight NormalFloat guibg=none
  "highlight FloatBorder guibg=none
  highlight StatusLine guibg=none
  highlight StatusLineNC guibg=none
  "highlight VertSplit guibg=none
  "highlight LineNr guibg=none
]]
