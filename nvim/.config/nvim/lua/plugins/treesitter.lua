-- Highlight, edit, and navigate code
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPost", "BufNewFile" },
  build = ":TSUpdate",
  branch = "main",
  config = function()
    local parsers = {
      "bash",
      "c",
      "cpp",
      "diff",
      "go",
      "html",
      "lua",
      "luadoc",
      "markdown",
      "markdown_inline",
      "query",
      "rust",
      "vim",
      "vimdoc",
    }
    local opts = {
      ensure_installed = parsers,
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    }

    require("nvim-treesitter").setup(opts)
  end,
}
