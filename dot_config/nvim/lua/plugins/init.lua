local keymap = require("core.keymap")

return {
  "editorconfig/editorconfig-vim",
  "tpope/vim-surround",
  "tpope/vim-repeat",
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
