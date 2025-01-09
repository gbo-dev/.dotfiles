-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer]' })

vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>fh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
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
vim.keymap.set('n', '<Leader>ss', '<Plug>(leap-forward-to)') -- Leap: replace s -> leader + s
vim.keymap.set('n', '<Leader>SS', '<Plug>(leap-backward-to)') -- Leap: replace S -> leader + S

-- Trouble pretty list 
vim.keymap.set('n', "<leader>xx", "<cmd>TroubleToggle<cr>")
vim.keymap.set('n', "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>")
vim.keymap.set('n', "<leader>xd", " <cmd>TroubleToggle document_diagnostics<cr>")
vim.keymap.set('n', "<leader>xq", " <cmd>TroubleToggle quickfix<cr>")
vim.keymap.set('n', "<leader>xl", " <cmd>TroubleToggle loclist<cr>")
--vim.keymap.set('n', "gR", "<cmd>TroubleToggle lsp_references<cr>")

-- Telescope edit shell/neovim
vim.keymap.set('n', '<leader>en', '<cmd>lua edit_neovim()<cr>')

-- nvim-tree bindings
vim.keymap.set('n', '<C-b>', ':NvimTreeToggle<CR>' )

-- View keybinds
vim.keymap.set('n', '<leader>kb', function()
    require('telescope.builtin').keymaps()
end, { desc="Lists all keybinds" })


vim.keymap.set({'n', 'i', 'v'}, '<F1>', '<NOP>', { silent = true }) -- Remove F1 help
vim.keymap.set('n', '<leader><F1>', ':help<CR>', { silent = true, noremap = true })
