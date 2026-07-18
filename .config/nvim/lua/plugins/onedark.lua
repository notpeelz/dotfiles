local au = require("core.au")
local plugin = require("core.plugin")

return plugin{
  "onedark.nvim",
  main = "onedark",
  opts = {
    style = "dark",
    highlights = {
      FoldColumn = { bg = "SignColumn" },
      Cursor = { fg = "$bg0", bg = "$fg", fmt = "NONE" },
    },
  },
  config = function()
    require("onedark").load()

    vim.opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,o:hor50-Cursor"

    -- workaround for https://github.com/navarasu/onedark.nvim/issues/260
    au.group("ThemeSync", {
      ColorScheme = {
        function()
          if vim.g.colors_name ~= "onedark" or not vim.g.onedark_config then
            return
          end
          local correct = vim.o.background == "light" and "light" or "dark"
          if vim.g.onedark_config.style ~= correct then
            local cfg = vim.g.onedark_config
            cfg.style = correct
            vim.g.onedark_config = cfg
          end
        end,
        pattern = "onedark",
      },
    })

    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "background",
      callback = function()
        vim.cmd.colorscheme("onedark")
      end,
    })
  end,
}
