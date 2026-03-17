-- Diagnostic configuration (Neovim 0.11+ style)
vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "single",
    source = "if_many",
  },
  underline = { severity = vim.diagnostic.severity.ERROR },
  virtual_text = true,
  virtual_lines = false,
  -- Auto open float when jumping with [d / ]d
  jump = { float = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})
