# Neovim config

Neovim 0.11+ configuration managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Requirements

**Neovim** 0.11 or newer (uses `vim.lsp.config` / `vim.lsp.enable`).

**External tools** (expected on `PATH`, not installed by this config):

| Tool | Used for |
|------|----------|
| `stylua` | Lua formatting (conform) |
| `oxfmt` | JS/TS/JSON formatting (conform) |
| `oxlint` | JS/TS linting (LSP) |
| `clangd`, `rust-analyzer`, `lua-language-server`, `gopls`, `zls` | Language servers (Mason can install these; formatters/linters above are not auto-installed) |

JS/TS tools also work from `node_modules/.bin` when inside a project. Example global install:

```sh
npm i -g oxlint oxfmt
```

## Layout

### `lua/config/`

| File | Purpose |
|------|---------|
| `lazy.lua` | Plugin manager bootstrap |
| `options.lua` | Editor options (leader, folds, clipboard, etc.) |
| `keymap.lua` | Global keymaps |
| `autocmd.lua` | Yank highlight, diagnostic hover float, spellcheck for markdown/text |
| `lsp-diagnostics.lua` | `vim.diagnostic` defaults |

`init.lua` loads the above, applies **gruvbox-baby**, and sets a fixed `#0a0a0a` background.

### `lua/plugins/`

| File | Plugins |
|------|---------|
| `colorschemes.lua` | gruvbox-baby |
| `editor.lua` | vim-sleuth, vim-repeat, plenary, leap, blink.cmp, mini.ai/move/pairs/surround, which-key, conform, persistence |
| `git.lua` | gitsigns |
| `lsp.lua` | fidget, mason, mason-lspconfig, nvim-lspconfig |
| `snacks.lua` | snacks.nvim (dashboard, picker, explorer, git, LSP navigation, toggles) |
| `treesitter.lua` | nvim-treesitter |
| `ui.lua` | todo-comments, trouble, lualine |

## LSP

Enabled servers: `clangd`, `rust_analyzer`, `lua_ls`, `gopls`, `zls`, `oxlint`.

- **Mason** installs LSP servers listed in `mason-lspconfig` (`ensure_installed`).
- **oxlint** provides JS/TS diagnostics; `:LspOxlintFixAll` applies safe fixes when attached.
- **oxfmt** LSP is disabled — formatting uses conform + CLI `oxfmt`.
- Buffer LSP maps: `grn` rename, `gra` code action, `grD` declaration. Navigation uses Snacks pickers (`gd`, `gr`, etc.).

## Formatting

[conform.nvim](https://github.com/stevearc/conform.nvim) runs on save (except C/C++ and per-buffer opt-out via `<leader>df`).

- `<leader>cf` — format buffer manually
- `<leader>df` — toggle format-on-save for current buffer

## Snacks

Primary UI layer: file picker (`<leader>ff`), smart find (`<leader><space>`), explorer (`<C-b>`), grep (`<leader>sg`), git pickers (`<leader>g*`), dashboard on start, zen mode (`<leader>z`).

Diagnostics/lists: Trouble (`<leader>x*`), Snacks picker (`<leader>sd`). Toggle diagnostics/virtual text via Snacks toggles (`<leader>ud`, `<leader>tv`, etc.) — see which-key (`<leader>?`).

## Other notes

- Leader: `<Space>`
- Netrw disabled; Snacks explorer replaces it
- Session restore via persistence.nvim (dashboard `s` key)
- Leap: `<leader>ss` / `<leader>SS`
