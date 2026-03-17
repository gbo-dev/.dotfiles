-- Leader keys (must be set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable netrw (using snacks explorer instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Line numbers
vim.o.number = true
vim.o.relativenumber = true

-- Always show signcolumn
vim.o.signcolumn = "yes"

-- Indentation
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.breakindent = true

-- Search
vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showmatch = true
vim.o.matchtime = 3

-- Don't show mode in cmdline (lualine shows it)
vim.o.showmode = false

-- Scrolling
vim.o.scrolloff = 10

-- Clipboard (scheduled to avoid slowing startup)
vim.schedule(function()
  vim.o.clipboard = "unnamedplus"
end)

-- Cursor
vim.o.cursorline = true

-- Completion
vim.o.completeopt = "menuone,noinsert,noselect"

-- Splits
vim.o.splitbelow = true
vim.o.splitright = true

-- Appearance
vim.o.termguicolors = true

-- Mouse
vim.o.mouse = "a"

-- Persistent undo
vim.o.undofile = true

-- Faster CursorHold
vim.o.updatetime = 250

-- Prompt to save instead of erroring on :q with unsaved changes
vim.o.confirm = true

-- Visible whitespace
vim.o.list = true
vim.opt.listchars = { tab = ">> ", trail = "·", nbsp = "␣" }

-- Treesitter-based folding
vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.o.foldcolumn = "0"
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldtext = ""

vim.o.report = 0
