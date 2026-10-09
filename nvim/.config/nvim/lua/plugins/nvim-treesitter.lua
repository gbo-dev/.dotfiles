-- Install parsers and enable Tree-sitter features for supported filetypes.
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
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
  "zig",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter")
    treesitter.install(parsers)

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter", { clear = true }),
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if not lang then
          return
        end

        local function start(err)
          if err or not vim.api.nvim_buf_is_valid(args.buf) or vim.bo[args.buf].filetype ~= args.match then
            return
          end
          if vim.treesitter.language.add(lang) then
            vim.treesitter.start(args.buf, lang)
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end

        if vim.treesitter.language.add(lang) then
          start()
        elseif vim.tbl_contains(treesitter.get_available(), lang) then
          treesitter.install(lang):await(start)
        end
      end,
    })
  end,
}
