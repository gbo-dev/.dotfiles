vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Open diagnostic float" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Exit terminal mode
-- vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Half-page scroll + center
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Search + center
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")

-- Splits
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split horizontal" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
vim.keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close split" })

-- Window navigation (standard Ctrl+hjkl)
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Quick save/quit
vim.keymap.set("n", "<A-q>", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<C-s>", ":w<CR>", { desc = "Save" })

-- Yank inside braces
vim.keymap.set("n", "YY", 'va{Vy"')

-- Leap
vim.keymap.set("n", "<Leader>ss", "<Plug>(leap-forward)", { desc = "Leap forward" })
vim.keymap.set("n", "<Leader>SS", "<Plug>(leap-backward)", { desc = "Leap backward" })

-- Trouble (v3 API)
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble: diagnostics" })
vim.keymap.set(
  "n",
  "<leader>xd",
  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  { desc = "Trouble: buffer diagnostics" }
)
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Trouble: quickfix" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Trouble: loclist" })

-- Disable F1 (accidental help), remap to leader
vim.keymap.set({ "n", "i", "v" }, "<F1>", "<NOP>", { silent = true })
vim.keymap.set("n", "<leader><F1>", ":help<CR>", { silent = true, noremap = true, desc = "Open help" })
