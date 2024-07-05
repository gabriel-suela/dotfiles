return {
  -- add gruvbox
  { "wittyjudge/gruvbox-material.nvim" },
  { "Mofiqul/vscode.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vscode",
    },
  },
}
