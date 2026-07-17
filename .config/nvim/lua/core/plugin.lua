local plugin_dir = vim.fn.stdpath("data") .. "/plugins"
local loaded = {}

local function normalize(spec)
  if type(spec) == "string" then
    return { name = spec, dependencies = {} }
  end

  local result = {
    name = spec[1],
    dependencies = {},
    init = spec.init,
    opts = spec.opts,
    main = spec.main,
    config = spec.config,
    keys = spec.keys,
    cond = spec.cond,
  }

  for _, dep in ipairs(spec.dependencies or {}) do
    table.insert(result.dependencies, normalize(dep))
  end

  return result
end

local function load(plugin)
  if not plugin.name then
    return
  end

  for _, dep in ipairs(plugin.dependencies or {}) do
    load(dep)
  end

  if plugin.cond ~= nil and not plugin.cond() then
    return
  end

  if not loaded[plugin.name] then
    loaded[plugin.name] = true
    vim.opt.rtp:prepend(plugin_dir .. "/" .. plugin.name)
  end

  if plugin.init then
    pcall(plugin.init)
  end

  if plugin.opts then
    local mod_name = plugin.main or plugin.name
    local ok, mod = pcall(require, mod_name)
    if ok and type(mod.setup) == "function" then
      mod.setup(plugin.opts)
    end
  end

  if plugin.config then
    plugin.config()
  end

  for _, km in ipairs(plugin.keys or {}) do
    local mode = km.mode
    local lhs = km[1]
    local rhs = km[2]
    local opts = {}
    for k, v in pairs(km) do
      if type(k) ~= "number" and k ~= "mode" then
        opts[k] = v
      end
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

return function(spec)
  load(normalize(spec))
end
