local plugin = require("core.plugin")

return plugin{
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
}
