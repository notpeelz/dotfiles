return {
  {
    "navarasu/onedark.nvim",
    event = "VimEnter",
    config = function()
      require("onedark").load()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
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
        lualine_c = { "filename" },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
}
