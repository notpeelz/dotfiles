local plugins = require("core.plugins")

return plugins{
  {
    "onedark.nvim",
    event = "VimEnter",
    init = function()
      require("onedark").load()
    end,
    opts = {
      style = "dark",
      highlights = {
        FoldColumn = { bg = "SignColumn" },
      },
    },
  },
  {
    "lualine.nvim",
    dependencies = {
      "onedark.nvim",
    },
    opts = {
      options = {
        icons_enabled = false,
        theme = "onedark",
        component_separators = "\u{2502}",
        section_separators = "",
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          { "branch", icons_enabled = true },
          "diff",
          "diagnostics",
        },
        lualine_c = { { "filename", path = 3 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { "filename", path = 3 } },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
  {
    "statuscol.nvim",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        segments = {
          { text = { "%s" }, click = "v:lua.ScSa" },
          {
            text = { builtin.lnumfunc, " " },
            click = "v:lua.ScLa",
            condition = {
              true,
              function()
                return vim.opt_local.number:get()
              end,
            },
          },
          { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" },
        },
      })
    end,
  },
  {
    "indent-blankline.nvim",
    main = "ibl",
    dependencies = {
      "nvim-treesitter",
    },
    opts = {
      indent = {
        priority = 12,
      },
    },
    cond = function()
      return vim.g.vscode == nil
    end,
  },
}
