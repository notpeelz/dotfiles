local plugin = require("core.plugin")

return plugin{
  "indent-blankline.nvim",
  main = "ibl",
  dependencies = {
    "nvim-treesitter",
  },
  init = function()
    -- workaround for https://github.com/lukas-reineke/indent-blankline.nvim/issues/986
    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.VIRTUAL_TEXT, function(_, _, _, virt_text)
      for _, vt in ipairs(virt_text) do
        if vt[2] then
          vt[2] = "IblIndent"
        end
      end
      return virt_text
    end)
  end,
  opts = {
    indent = {
      char = "│",
      tab_char = "│",
      priority = 12,
    },
  },
  cond = function()
    return vim.g.vscode == nil
  end,
}
