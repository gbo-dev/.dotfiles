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
require("plugins.lualine")
require("plugins.treesitter")
require("plugins.snacks")

vim.cmd [[colorscheme gruvbox-baby]]
--vim.cmd [[ colorscheme tokyodark ]]
