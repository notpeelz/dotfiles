local keymap = require("core.keymap")

local function make_picker(o)
  local function attach_mappings(_, map)
    local actions = require("telescope.actions")
    map("i", "<C-a>", { type = "command", "<Home>" })
    map("i", "<C-e>", { type = "command", "<End>" })
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
    keys = {
      keymap.mapping{
        "n",
        "<Space>ff",
        make_picker{
          function(...)
            local builtin = require("telescope.builtin")
            return builtin.find_files(...)
          end
        },
      },
      keymap.mapping{
        "n",
        "<Space>fb",
        make_picker{
          function(...)
            local builtin = require("telescope.builtin")
            return builtin.buffers(...)
          end
        },
      },
      keymap.mapping{
        "n",
        "<Space>fh",
        make_picker{
          function(...)
            local builtin = require("telescope.builtin")
            return builtin.help_tags(...)
          end
        },
      },
    },
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      keymap.mapping{
        "n",
        "<Space>fs",
        make_picker{
          function(...)
            local fb = require("telescope").extensions.file_browser
            return fb.file_browser(...)
          end
        }
      },
    }
  },
  {
    "nvim-telescope/telescope-live-grep-args.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    keys = {
      keymap.mapping{
        "n",
        "<Space>fg",
        make_picker{
          function(...)
            local lga = require("telescope").extensions.live_grep_args
            return lga.live_grep_args(...)
          end,
          mappings = function(map)
            local function quote_prompt(bufnr)
              local action_state = require("telescope.actions.state")
              local picker = action_state.get_current_picker(bufnr)
              local prompt = picker:_get_prompt()
              prompt = vim.trim(prompt)
              prompt = "-- \"" .. prompt:gsub("\"", "\\\"") .. "\""
              picker:set_prompt(prompt)
              vim.cmd.normal{ "I", bang = true }
            end

            map("i", "<C-k>", quote_prompt)
          end,
        },
      },
    },
  },
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      { "nvim-treesitter/nvim-treesitter", optional = true },
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
  },
}
