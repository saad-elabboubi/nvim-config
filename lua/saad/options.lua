vim.g.mapleader = " "
vim.g.maplocalleader = " "

local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
local llvm_bin = "/opt/homebrew/opt/llvm/bin"
vim.env.PATH = llvm_bin .. ":" .. mason_bin .. ":" .. vim.env.PATH

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.breakindent = true
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.timeoutlen = 400
opt.splitright = true
opt.splitbelow = true
opt.termguicolors = true
opt.cursorline = false
opt.guicursor = {
	"n-v-c:block-Cursor/lCursor",
	"i-ci-ve:ver25-Cursor/lCursor",
	"r-cr:hor20-Cursor/lCursor",
	"o:hor50-Cursor/lCursor",
	"a:blinkwait700-blinkoff400-blinkon250",
	"sm:block-blinkwait175-blinkoff150-blinkon175",
}
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.confirm = true
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.wrap = false
opt.list = true
opt.listchars = { tab = "> ", trail = ".", nbsp = "+" }
opt.inccommand = "split"
opt.winbar = "  %f %m"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text",
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 150 })
	end,
})
