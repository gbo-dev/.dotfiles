-- Highlight, edit, and navigate code
return {
  "nvim-treesitter/nvim-treesitter",
  lazy = false,
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
    require("nvim-treesitter").install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      desc = "Enable treesitter highlighting and indentation",
      group = vim.api.nvim_create_augroup("treesitter-setup", { clear = true }),
      callback = function(args)
        local buf, filetype = args.buf, args.match

        local language = vim.treesitter.language.get_lang(filetype)
        if not language then
          return
        end

        -- Check if parser exists and load it
        if not vim.treesitter.language.add(language) then
          return
        end

        -- Enable syntax highlighting
        vim.treesitter.start(buf, language)

        -- Enable treesitter-based indentation
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
