return {
  {
    "xeind/nightingale.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("nightingale").setup({
        transparent = false, -- set to true for transparent background
      })
      vim.cmd("colorscheme nightingale")
    end,
  },
}
