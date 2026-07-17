local keymap = require("core.keymap")
local plugin = require("core.plugin")

return plugin{
  "vim-ReplaceWithRegister",
  keys = {
    keymap.mapping{ "n", "r", "<nop>" },
    keymap.mapping{ "x", "r", "<nop>" },
    keymap.mapping{ "n", "rc", "r" },
    keymap.mapping{ "x", "rc", "r" },
    keymap.mapping{ "n", "rr", "<Plug>ReplaceWithRegisterOperator" },
    keymap.mapping{ "n", "r^", "<Plug>ReplaceWithRegisterLine" },
    keymap.mapping{ "x", "rr", "<Plug>ReplaceWithRegisterVisual" },
  },
}
