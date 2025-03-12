-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.api.nvim_create_augroup("FileAssociations", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { "", "", "" })
  end
})

vim.api.nvim_create_autocmd("BufRead,BufNewFile", {
  group = "FileAssociations",
  pattern = "*.yaml.gotmpl",
  command = "setfiletype yaml",
})
