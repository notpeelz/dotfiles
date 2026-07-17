local keymap = require("core.keymap")
local plugin = require("core.plugin")

local function make_picker(o)
  local function attach_mappings(_, map)
    local actions = require("telescope.actions")
    map({ "n", "i" }, "<Tab>", actions.toggle_selection)
    map({ "n", "i" }, "<S-Tab>", nil)
    map({ "n", "i" }, "<C-Up>", actions.cycle_history_prev)
    map({ "n", "i" }, "<C-Down>", actions.cycle_history_next)
    map("n", "<C-c>", "close")
    if type(o.mappings) == "function" then
      o.mappings(map)
    end
    return true
  end

  return function()
    return o[1]{
      attach_mappings = attach_mappings,
    }
  end
end

return plugin{
  "aerial.nvim",
  main = "aerial",
  dependencies = {
    "telescope.nvim",
    "nvim-treesitter",
  },
  opts = {},
  keys = {
    keymap.mapping{ "n",
      "<Space>fo",
      make_picker{
        function(...)
          local aerial = require("telescope").extensions.aerial
          aerial.aerial(...)
        end,
      },
    },
  },
}
