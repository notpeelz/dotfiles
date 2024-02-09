local S = {}

function S.group(name, cmds)
  local group = vim.api.nvim_create_augroup(name, {})
  local function create_cmds(t)
    for event, o in pairs(t) do
      local opts = {}
      if type(o) == "table" then
        local callback = o[1]
        if type(callback) ~= "function" then
          error("autocmd group entry[1] should be a function")
        end
        for k, v in pairs(o) do
          if type(k) ~= "number" then
            opts[k] = v
          end
        end
        opts.callback = callback
      elseif type(o) == "function" then
        opts.callback = o
      else
        error("invalid autocmd group entry; expected a table or a function")
      end

      opts.group = group

      vim.api.nvim_create_autocmd(event, opts)
    end
  end

  if type(cmds) == "function" then
    create_cmds(cmds())
  else
    create_cmds(cmds)
  end
end

return S
