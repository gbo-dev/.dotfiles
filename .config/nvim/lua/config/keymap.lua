-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')
vim.keymap.set('n', '<leader>sv', '<C-w>v')
vim.keymap.set('n', '<leader>sh', '<C-w>s')
vim.keymap.set('n', '<leader>se', '<C-w>=')
vim.keymap.set('n', '<leader>sx', ':close<CR>')
--vim.keymap.set('n', '<leader>1', '1gt')
vim.keymap.set('n', '<A-q>', ':q<CR>')
vim.keymap.set('n', '<C-s>', ':w<CR>')
vim.keymap.set('n', 'YY', 'va{Vy"')
vim.keymap.set('n', '<Leader>ss', '<Plug>(leap-forward-to)')  -- Leap: replace s -> leader + s
vim.keymap.set('n', '<Leader>SS', '<Plug>(leap-backward-to)') -- Leap: replace S -> leader + S

-- Trouble pretty list
vim.keymap.set('n', "<leader>xx", "<cmd>TroubleToggle<cr>")
vim.keymap.set('n', "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
vim.keymap.set('n', "<leader>xd", " <cmd>TroubleToggle document_diagnostics<cr>")
vim.keymap.set('n', "<leader>xq", " <cmd>TroubleToggle quickfix<cr>")
vim.keymap.set('n', "<leader>xl", " <cmd>TroubleToggle loclist<cr>")
--vim.keymap.set('n', "gR", "<cmd>TroubleToggle lsp_references<cr>")

vim.keymap.set({ 'n', 'i', 'v' }, '<F1>', '<NOP>', { silent = true }) -- Remove F1 help
vim.keymap.set('n', '<leader><F1>', ':help<CR>', { silent = true, noremap = true })
