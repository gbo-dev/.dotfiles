
-- Vim options
vim.wo.number = true -- Make line numbers default
vim.wo.cursorline = true
vim.wo.signcolumn = 'yes'
vim.bo.softtabstop = 2 vim.opt.incsearch = true
vim.opt.scrolloff = 3
vim.opt.relativenumber = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.wildmenu = true
vim.opt.completeopt = {'menuone', 'noinsert', 'noselect'}
vim.opt.smartcase = true
vim.opt.expandtab = true
vim.opt.showmatch = true
vim.opt.matchtime = 3
vim.o.hlsearch = false -- Set highlight on search
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.smartindent = true
vim.o.termguicolors = true-- Set colorscheme
vim.o.mouse = 'a' -- Enable mouse mode
vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true -- Save undo history
vim.o.ignorecase = true -- Case insensitive searching UNLESS /C or capital in search
vim.o.smartcase = true
vim.o.updatetime = 250 -- Decrease update time

-- Folding 
vim.opt.foldmethod = "expr" -- 'za' to toggle folds
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldtext = ""

-- Vim editor globals
vim.g.mapleader = ' ' 
vim.g.maplocalleader = ' '

vim.g.loaded_netrw = 1 -- disable netrw at the very start of your init.lua 
vim.g.loaded_netrwPlugin = 1

-- Colorscheme-related
vim.g.indent_blankline_char = "│" -- "|" is default
vim.g.gruvbox_baby_background_color = "dark"
