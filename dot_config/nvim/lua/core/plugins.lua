local function get_plugin_path(spec)
  return string.format(
    "%s/lazy/%s",
    vim.fn.stdpath("data"),
    spec[1] or spec.dir or spec.name
  )
end

local function make_plugin(spec)
  if type(spec) == "string" then
    return {
      dir = get_plugin_path({ spec }),
    }
  end

  for k, v in ipairs(spec.dependencies or {}) do
    if type(v) == "string" then
      local path = get_plugin_path({ v })
      spec.dependencies[k] = { dir = path }
    elseif type(v) == "table" then
      if type(v[1]) == "string" then
        v.dir = get_plugin_path(v)
        table.remove(v, 1)
      end
    end
  end

  spec.dir = get_plugin_path(spec)
  table.remove(spec, 1)
  return spec
end

return function(t)
  for k, v in ipairs(t) do
    t[k] = make_plugin(v)
  end
  return t
end
