local keymap = require("core.keymap")

local instance = nil
function get()
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

local lazyterm = {}
setmetatable(lazyterm, {
  __index = function(_, k)
    return get()[k]
  end,
})

return {
  {
    "akinsho/toggleterm.nvim",
    keys = {
      keymap.mapping{
        { "n", "t" },
        "<C-t>",
        function()
          lazyterm:toggle()
        end,
      }
    }
  },
}
