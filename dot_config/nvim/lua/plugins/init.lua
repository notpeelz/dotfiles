local keymap = require("core.keymap")
local plugins = require("core.plugins")

return plugins{
  "vim-rzip",
  {
    "nvim-unception",
    init = function()
      vim.g.unception_open_buffer_in_new_tab = true
      vim.g.unception_enable_flavor_text = false
    end,
    cond = function()
      -- unception doesn't play nice with fugitive's interactive rebase
      return os.getenv("GIT_EXEC_PATH") == nil
    end,
  },
  {
    "suda.vim",
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
    "nvim-surround",
    opts = {},
  },
  {
    "vim-ReplaceWithRegister",
    lazy = false,
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
    "nvim-ufo",
    lazy = false,
    dependencies = {
      "nvim-treesitter",
      "promise-async",
      "statuscol.nvim",
    },
    keys = {
      keymap.mapping{
        "n",
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
      },
      keymap.mapping{
        "n",
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
      },
    },
    opts = {
      event = "BufReadPost",
      provider_selector = function(bufnr, filetype, buftype)
        return { "treesitter", "indent" }
      end,
    },
  },
  {
    "comment.nvim",
    dependencies = {
      "nvim-treesitter",
    },
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
    "vim-matchup",
    dependencies = {
      "nvim-treesitter",
    },
  },
}
