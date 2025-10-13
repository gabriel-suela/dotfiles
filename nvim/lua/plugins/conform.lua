return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- Add support for .yaml.gotmpl files
    opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
      ["yaml.gotmpl"] = { "prettier" },
    })

    -- Tell prettier to always use the YAML parser for these
    opts.formatters = vim.tbl_extend("force", opts.formatters or {}, {
      prettier = {
        prepend_args = { "--parser", "yaml" },
      },
    })
  end,
}
