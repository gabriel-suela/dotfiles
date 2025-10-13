return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "night" },
  },

  { "Mofiqul/vscode.nvim", name = "vscode", lazy = false, priority = 1000 },
  vim.cmd.colorscheme("vscode"),
}
