return {
  "mason-org/mason-lspconfig.nvim",
  lazy = false,
  opts = {
    ensure_installed = { "clangd", "rust_analyzer", "lua_ls", "gopls", "zls" },
    automatic_enable = {
      exclude = { "oxfmt" },
    },
  },
}
