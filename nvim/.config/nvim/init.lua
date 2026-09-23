vim.loader.enable()

require("config.options")
require("config.lazy")
require("config.autocmd")
require("config.lsp-diagnostics")
require("config.keymap")
require("config.dim")

vim.cmd.colorscheme("gruvbox-baby")
