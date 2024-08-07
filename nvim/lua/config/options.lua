-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = "unnamedplus"

vim.cmd([[au BufNewFile,BufRead *.yaml.gotmpl setf yaml]])
vim.g.lazyvim_prettier_needs_config = false
