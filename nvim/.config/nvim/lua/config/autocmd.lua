-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("spellcheck", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.spell = true
  end,
})
