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
      "javascript",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "query",
      "regex",
      "rust",
      "toml",
      "tsx",
      "vim",
      "vimdoc",
      "yaml",
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
