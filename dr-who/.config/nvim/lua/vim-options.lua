vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
-- Show absolute line number for the current line
vim.opt.number = true
vim.opt.termguicolors = true
-- Show relative line numbers for all other lines
vim.opt.relativenumber = true
vim.g.mapleader = " " -- Sets Space as your leader key
vim.g.maplocalleader = "\\"
-- Navigate windows faster (no more Ctrl-w)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode with jk" })
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit Insert Mode with kj" })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
