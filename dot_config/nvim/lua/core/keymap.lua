local S = {}

local function with_default_opts(mode, opts)
  if opts.noremap == nil and opts.remap == nil then
    opts.noremap = true
  end
  if opts.silent == nil then
    opts.silent = true
  end
end

function S.mapping(o)
  with_default_opts(o)
  o.mode = table.remove(o, 1)
  return o
end

function S.map_buf(bufnr, mode, l, r, opts)
  local opts = opts or {}
  with_default_opts(opts)
  opts.buffer = bufnr
  vim.keymap.set(mode, l, r, opts)
end

function S.map(mode, l, r, opts)
  local opts = opts or {}
  with_default_opts(opts)
  vim.keymap.set(mode, l, r, opts)
end

return S
