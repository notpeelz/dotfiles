local keymap = require("core.keymap")

local function make_picker(o)
  local actions = require("telescope.actions")
  local function attach_mappings(_, map)
    map({ "n", "i" }, "<Tab>", actions.toggle_selection)
    map({ "n", "i" }, "<S-Tab>", nil)
    map("n", "<C-c>", "close")
    return true
  end
  return function()
    return o[1]{
      attach_mappings = attach_mappings,
    }
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    extensions = {
      aerial = {},
    },
    opts = {},
    keys = function()
      local builtin = require("telescope.builtin")
      return {
        keymap.mapping{ "n", "<Space>ff", make_picker{ builtin.find_files } },
        keymap.mapping{ "n", "<Space>fg", make_picker{ builtin.live_grep } },
        keymap.mapping{ "n", "<Space>fb", make_picker{ builtin.buffers } },
        keymap.mapping{ "n", "<Space>fh", make_picker{ builtin.help_tags } },
      }
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = function()
      local fb = require("telescope").extensions.file_browser
      return {
        keymap.mapping{ "n", "<Space>fs", make_picker{ fb.file_browser } },
      }
    end,
  },
  {
    "stevearc/aerial.nvim",
    opts = {},
    keys = function()
      local telescope = require("telescope")
      return {
        keymap.mapping{ "n", "<Space>fo", make_picker{ telescope.extensions.aerial.aerial } }
      }
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
      { "nvim-treesitter/nvim-treesitter", optional = true },
    },
  },
}
