local keymap = require("core.keymap")

return {
  "editorconfig/editorconfig-vim",
  "tpope/vim-surround",
  "tpope/vim-repeat",
  {
    "lambdalisue/suda.vim",
    config = function()
      local cmds = {
        { "W", "write" },
        { "E", "edit" },
        { "TabEdit", "tabedit" },
      }
      for _, cmd in ipairs(cmds) do
        vim.api.nvim_create_user_command(cmd[1], function(p)
          local args = string.len(p.args) == 0 and vim.fn.expand("%:p") or p.args
          if string.len(args) == 0 then
            vim.api.nvim_echo({
              { "E32: No file name", "ErrorMsg" },
            }, true, {})
            return
          end
          if p.bang then
            vim.api.nvim_command(cmd[2] .. "! suda://" .. args)
          else
            vim.api.nvim_command(cmd[2] .. " suda://" .. args)
          end
        end, {
          complete = "file",
          nargs = "?",
          bang = true,
        })
      end
    end,
  },
  {
    "inkarkat/vim-ReplaceWithRegister",
    keys = {
      keymap.mapping{ "n", "r", "<nop>" },
      keymap.mapping{ "x", "r", "<nop>" },
      keymap.mapping{ "n", "rc", "r" },
      keymap.mapping{ "x", "rc", "r" },
      keymap.mapping{ "n", "rr", "<Plug>ReplaceWithRegisterOperator" },
      keymap.mapping{ "n", "r^", "<Plug>ReplaceWithRegisterLine" },
      keymap.mapping{ "x", "rr", "<Plug>ReplaceWithRegisterVisual" },
    },
  },
  {
    "numToStr/Comment.nvim",
    tag = (function()
      if vim.fn.has("nvim-0.7") == 0 then
        return "v0.6"
      end
    end)(),
    opts = {
      basic = true,
      extended = true,
    },
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      use_treesitter = false,
      buftype_exclude = {
        "terminal"
      },
      filetype_exclude = {
        "help",
      },
    },
    cond = function()
      return vim.g.vscode == nil
    end,
  },
}
