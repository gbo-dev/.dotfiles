
### Core Configuration (`lua/config/`)

*   `autocmd.lua`: Contains custom autocommands.
*   `keymap.lua`: Defines custom key mappings.
*   `lazy.lua`: `lazy.nvim` plugin manager setup.
*   `lsp-diagnostics.lua`: Configuration for LSP diagnostics and handlers (like `on_attach`).
*   `options.lua`: Sets core Neovim options.

### Plugins (`lua/plugins/`)

Plugin specifications are managed by `lazy.nvim`. Key plugins include:

*   **`colorschemes.lua`**:
    *   Manages colorscheme plugins (e.g., `gruvbox-baby`, `tokyodark.nvim`).
*   **`editor.lua`**:
    *   General editing enhancements (e.g., `tpope/vim-sleuth`, `tpope/vim-repeat`, `ggandor/leap.nvim`, `junegunn/fzf.vim`, `windwp/nvim-autopairs`, `echasnovski/mini.move`, `github/copilot.vim`).
    *   Dependencies like `nvim-lua/plenary.nvim`.
*   **`git.lua`**:
    *   Git integration (e.g., `tpope/vim-fugitive`, `tpope/vim-rhubarb`, `lewis6991/gitsigns.nvim`).
*   **`lsp.lua`**:
    *   Language Server Protocol setup (e.g., `neovim/nvim-lspconfig`, `williamboman/mason.nvim`, `williamboman/mason-lspconfig.nvim`, `j-hui/fidget.nvim`).
    *   Completion (e.g., `saghen/blink.cmp` or your chosen completion plugin).
*   **`snacks.lua`**:
    *   Configuration for `folke/snacks.nvim` (a suite of UI/UX enhancements).
*   **`treesitter.lua`**:
    *   Syntax highlighting and code parsing via `nvim-treesitter/nvim-treesitter`.
    *   Additional textobjects (e.g., `nvim-treesitter/nvim-treesitter-textobjects`).
*   **`ui.lua`**:
    *   User interface elements (e.g., `nvim-lualine/lualine.nvim`, `folke/todo-comments.nvim`, `folke/trouble.nvim`, `lukas-reineke/indent-blankline.nvim`, `ap/vim-css-color`, `m-demare/hlargs.nvim`, `MeanderingProgrammer/render-markdown.nvim`).

---
