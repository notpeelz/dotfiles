local plugin = require("core.plugin")

return plugin{
  "onedark.nvim",
  main = "onedark",
  opts = {
    style = "dark",
    highlights = {
      FoldColumn = { bg = "SignColumn" },
    },
  },
  config = function()
    require("onedark").load()
  end,
}
