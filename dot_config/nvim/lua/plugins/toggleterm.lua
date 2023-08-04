local keymap = require("core.keymap")

return {
  {
    "akinsho/toggleterm.nvim",
    keys = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local term = Terminal:new({
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
          vim.cmd("startinsert!")
        end,
      })

      function toggle()
        term:toggle()
      end

      return {
        keymap.mapping{ { "n", "t" }, "<C-t>", toggle }
      }
    end,
  },
}
