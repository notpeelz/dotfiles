local plugin = require("core.plugin")

return plugin{
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
}
