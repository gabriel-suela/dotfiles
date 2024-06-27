return {
  {
    "aserowy/tmux.nvim",
    keys = {
      {
        "<c-h>",
        function()
          require("tmux").move_left()
        end,
        desc = "tmux move left",
      },
      {
        "<c-j>",
        function()
          require("tmux").move_bottom()
        end,
        desc = "tmux move bottom",
      },
      {
        "<c-k>",
        function()
          require("tmux").move_top()
        end,
        desc = "tmux move top",
      },
      {
        "<c-l>",
        function()
          require("tmux").move_right()
        end,
        desc = "tmux move right",
      },
    },
    opts = {
      navigation = {
        enable_default_keybindings = false,
      },
    },
  },
}
