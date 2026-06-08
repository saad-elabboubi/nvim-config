local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>Q", "<cmd>qa<CR>", { desc = "Quit all" })

map("n", "<leader>sv", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>sh", "<cmd>split<CR>", { desc = "Split horizontal" })
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close split" })
map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Grow split height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Shrink split height" })
map("n", "<C-Left>", "<cmd>vertical resize -4<CR>", { desc = "Shrink split width" })
map("n", "<C-Right>", "<cmd>vertical resize +4<CR>", { desc = "Grow split width" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
map("n", "J", "mzJ`z", { desc = "Join lines and keep cursor" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half-page down centered" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half-page up centered" })
map("n", "<C-e>", "<C-e>zz", { desc = "Scroll one line down centered" })
map("n", "<C-y>", "<C-y>zz", { desc = "Scroll one line up centered" })
map("n", "n", "nzzzv", { desc = "Next result centered" })
map("n", "N", "Nzzzv", { desc = "Previous result centered" })

map("n", "<leader>bn", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<leader>bl", "<cmd>ls<CR>", { desc = "List buffers" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Leave terminal mode" })

-- Quick Esc on AZERTY (kj to leave insert mode)
map("i", "kj", "<Esc>", { desc = "Quick Esc" })
map("t", "kj", "<C-\\><C-n>", { desc = "Quick leave terminal mode" })
