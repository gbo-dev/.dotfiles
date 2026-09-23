-- Format buffers with external tools and LSP fallback.
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[C]ode [F]ormat buffer",
    },
    {
      "<leader>df",
      function()
        vim.b.disable_autoformat = not vim.b.disable_autoformat
        local state = vim.b.disable_autoformat and "disabled" or "enabled"
        vim.notify("Format-on-save " .. state .. " for this buffer")
      end,
      desc = "[D]isable [F]ormat-on-save (buffer)",
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      if vim.b[bufnr].disable_autoformat then
        return nil
      end
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      end
      return {
        timeout_ms = 500,
        lsp_format = "fallback",
      }
    end,
    formatters_by_ft = {
      lua = { "stylua" },
      -- go = { "gofmt" },  -- gopls handles this via LSP fallback
      -- python = { "isort", "black" },
      javascript = { "oxfmt" },
      typescript = { "oxfmt" },
      javascriptreact = { "oxfmt" },
      typescriptreact = { "oxfmt" },
      json = { "oxfmt" },
      jsonc = { "oxfmt" },
    },
  },
}
