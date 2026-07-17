local keymap = require("core.keymap")
local plugin = require("core.plugin")

return plugin{
  "nvim-treesitter-context",
  main = "treesitter-context",
  dependencies = {
    "nvim-treesitter",
  },
  opts = {
    enable = true,
    line_numbers = true,
    trim_scope = "outer",
    mode = "topline",
    separator = nil,
    zindex = 20,
    on_attach = nil,
  },
  keys = {
    keymap.mapping{ "n",
      "[p",
      function(...)
        local ctx = require("treesitter-context")
        return ctx.go_to_context(...)
      end,
    },
  },
}
