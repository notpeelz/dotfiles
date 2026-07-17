local keymap = require("core.keymap")
local plugin = require("core.plugin")

return plugin{
  "nvim-ufo",
  main = "ufo",
  dependencies = {
    "nvim-treesitter",
    "promise-async",
    "statuscol.nvim",
  },
  keys = {
    keymap.mapping{
      "n",
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
    },
    keymap.mapping{
      "n",
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
    },
  },
  opts = {
    event = "BufReadPost",
    provider_selector = function(bufnr, filetype, buftype)
      return { "treesitter", "indent" }
    end,
  },
}
