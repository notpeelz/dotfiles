local S = {}

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
  opts.buffer = bufnr
  vim.keymap.set(mode, l, r, opts)
end

function S.map(mode, l, r, opts)
  opts = get_opts(opts)
  vim.keymap.set(mode, l, r, opts)
end

return S
