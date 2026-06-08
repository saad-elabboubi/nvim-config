# Saad's Neovim Config

This repository contains my personal Neovim setup, built around `lazy.nvim`.

## What's included

- Lua-based Neovim config
- Plugin definitions in `lua/saad/plugins.lua`
- Locked plugin versions in `lazy-lock.json`
- Keymap notes in `KEYMAPS.md`
- LSP, formatting, debugging, git, terminal, and file navigation setup

## Main plugins

- `catppuccin`
- `which-key.nvim`
- `lualine.nvim`
- `vim-tmux-navigator`
- `nvim-treesitter`
- `nvim-treesitter-textobjects`
- `telescope.nvim`
- `oil.nvim`
- `gitsigns.nvim`
- `lazygit.nvim`
- `trouble.nvim`
- `blink.cmp`
- `nvim-autopairs`
- `nvim-lspconfig`
- `mason.nvim`
- `mason-tool-installer.nvim`
- `conform.nvim`
- `clangd_extensions.nvim`
- `nvim-dap`
- `nvim-dap-ui`
- `toggleterm.nvim`
- `flash.nvim`
- `no-neck-pain.nvim`
- `smear-cursor.nvim`
- `mini.icons`
- `vim-be-good`

## Install

1. Clone this repo into `~/.config/nvim`
2. Open `nvim`
3. Let `lazy.nvim` install plugins automatically
4. Run `:Mason` if you want to inspect or manage external tools

## External dependencies

This config works best with a few tools installed on the machine:

- `git`
- `make`
- `tmux`
- `lazygit`
- a Nerd Font
- Mason-managed tools such as `lua-language-server`, `typescript-language-server`, `ruff`, `prettier`, `stylua`, and `codelldb`

## Notes

- `lua/saad/options.lua` prepends `/opt/homebrew/opt/llvm/bin` to `PATH`, so non-Homebrew systems may want to adjust that.
- `lua/saad/commands.lua` includes some `Mistral*` commands that are specific to one project workflow.
- `lazy-lock.json` is included so the plugin versions stay reproducible.