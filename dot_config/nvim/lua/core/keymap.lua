local S = {
  _fns = {},
}

local function create_mapping(mode, l, func, expr)
  local func_name = mode .. "_" .. l
  S._fns[func_name] = func

  func_name = func_name
    :gsub("'", "\\'")
    :gsub('"', '\\"')
    :gsub("<", "<lt>")
    -- :gsub("%[", "[")
    -- :gsub("%]", "]")

  -- TODO: support expr mappings; couldn't get nvim_exec_lua() to work :(
  local cmd = "<cmd>lua require('core.keymap')._fns['" .. func_name .. "']()<CR>"
  if mode == "i" then
    cmd = "<C-o>" .. cmd
  end

  return cmd
end

local function get_opts(opts)
  opts = opts or {}
  if opts.noremap == nil then
    opts.noremap = true
  end
  if opts.silent == nil then
    opts.silent = true
  end
  return opts
end

function S.map_buf(bufnr, mode, l, r, opts)
  opts = get_opts(opts)

  if type(r) == "function" then
    r = create_mapping(mode, l, r)
  end

  if type(mode) == "table" then
    for _, mode in ipairs(mode) do
      vim.api.nvim_buf_set_keymap(bufnr, mode, l, r, opts or default_opts)
    end
  else
    vim.api.nvim_buf_set_keymap(bufnr, mode, l, r, opts or default_opts)
  end
end

function S.map(bufnr, mode, l, r, opts)
  opts = get_opts(opts)

  if type(r) == "function" then
    r = create_mapping(mode, l, r)
  end

  if type(mode) == "table" then
    for _, mode in ipairs(mode) do
      vim.api.nvim_set_keymap(bufnr, mode, l, r, opts or default_opts)
    end
  else
    vim.api.nvim_set_keymap(bufnr, mode, l, r, opts or default_opts)
  end
end

return S