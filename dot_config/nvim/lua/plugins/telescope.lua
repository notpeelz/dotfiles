local keymap = require("core.keymap")

return {
  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<Tab>"] = "toggle_selection",
            ["<S-Tab>"] = nil,
          },
          n = {
            ["<Tab>"] = "toggle_selection",
            ["<S-Tab>"] = nil,
          },
        },
      },
    },
    keys = function()
      local builtin = require("telescope.builtin")
      return {
        keymap.mapping{ "n", "<Space>ff", builtin.find_files },
        keymap.mapping{ "n", "<Space>fg", builtin.live_grep },
        keymap.mapping{ "n", "<Space>fb", builtin.buffers },
        keymap.mapping{ "n", "<Space>fh", builtin.help_tags },
      }
    end,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    keys = function()
      local fb = require("telescope").extensions.file_browser
      return {
        keymap.mapping{ "n", "<Space>fs", fb.file_browser },
      }
    end,
  },
}
