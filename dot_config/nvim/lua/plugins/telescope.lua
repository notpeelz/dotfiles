local keymap = require("core.keymap")

local function make_picker(o)
  local actions = require("telescope.actions")
  local function attach_mappings(_, map)
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

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    extensions = {
      aerial = {},
      live_grep_args = {
        auto_quoting = true,
      },
    },
    opts = {},
    keys = function()
      local builtin = require("telescope.builtin")
      return {
        keymap.mapping{ "n", "<Space>ff", make_picker{ builtin.find_files } },
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
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = function()
      local lga = require("telescope").extensions.live_grep_args
      local action_state = require("telescope.actions.state")
      local function quote_prompt(bufnr)
        local picker = action_state.get_current_picker(bufnr)
        local prompt = picker:_get_prompt()
        prompt = vim.trim(prompt)
        prompt = "-- \"" .. prompt:gsub("\"", "\\\"") .. "\""
        picker:set_prompt(prompt)
        vim.cmd.normal{ "I", bang = true }
      end

      return {
        keymap.mapping{
          "n",
          "<Space>fg",
          make_picker{
            lga.live_grep_args,
            mappings = function(map)
              map("i", "<C-k>", quote_prompt)
            end,
          }
        }
      }
    end,
  },
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      { "nvim-treesitter/nvim-treesitter", optional = true },
    },
    opts = {},
    keys = function()
      local aerial = require("telescope").extensions.aerial
      return {
        keymap.mapping{ "n", "<Space>fo", make_picker{ aerial.aerial } }
      }
    end,
  },
}
