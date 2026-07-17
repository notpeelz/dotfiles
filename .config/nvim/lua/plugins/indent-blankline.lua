local plugin = require("core.plugin")

return plugin{
  "indent-blankline.nvim",
  main = "ibl",
  dependencies = {
    "nvim-treesitter",
  },
  opts = {
    indent = {
      char = "│",
      tab_char = "│",
      priority = 12,
    },
  },
  cond = function()
    return vim.g.vscode == nil
  end,
}
