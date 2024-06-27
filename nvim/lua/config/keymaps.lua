-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Close buffer
keymap.set("n", "<leader>q", "<cmd>bd<CR>", opts)

-- Clear search with <esc>
keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", opts)

-- Move block
keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

-- surrounding words
keymap.set("n", "<leader>wsq", 'ciw""<Esc>P', opts)

-- bracket words
keymap.set("n", "<leader>wsb", "ciw{}<Esc>P", opts)
