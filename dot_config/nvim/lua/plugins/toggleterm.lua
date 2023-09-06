local keymap = require("core.keymap")
local au = require("core.au")

local instance = nil
function get_or_create_term()
  local Terminal = require("toggleterm.terminal").Terminal
  instance = instance or Terminal:new({
    direction = "float",
    hidden = true,
    float_opts = {
      border = "curved",
    },
    highlights = {
      Normal = {},
      NormalFloat = {},
      FloatBorder = {
        link = "TelescopePromptBorder",
      },
    },
    on_open = function(term)
      vim.cmd.startinsert{ bang = true }
    end,
  })
  return instance
end

return {
  {
    "akinsho/toggleterm.nvim",
    init = function()
      au.group("FloatTermUnfocus", {
        WinLeave = function(e)
          if instance == nil or e.buf ~= instance.bufnr then
            return
          end

          instance:close()
        end
      })
    end,
    keys = {
      keymap.mapping{
        { "n", "t" },
        "<C-t>",
        function()
          local term = get_or_create_term()
          term:toggle()
        end,
      }
    }
  },
}
