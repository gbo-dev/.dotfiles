-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Open diagnostics float on CursorHold (respects toggle state)
vim.api.nvim_create_autocmd("CursorHold", {
  desc = "Show diagnostics float on hover",
  group = vim.api.nvim_create_augroup("diagnostic-float", { clear = true }),
  callback = function()
    if not vim.diagnostic.is_enabled({ bufnr = 0 }) then
      return
    end
    if vim.diagnostic.config().virtual_text == false then
      return
    end
    vim.diagnostic.open_float(nil, { focusable = false })
  end,
})
