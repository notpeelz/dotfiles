local S = {}

local function with_default_opts(mode, opts)
  if opts.noremap == nil and opts.remap == nil then
    opts.noremap = true
  end

  if opts.silent == nil then
    local is_command_mapping = mode == "c"
    if type(mode) == "table" and vim.tbl_contains(mode, "c") then
      is_command_mapping = true
    end

    if not is_command_mapping then
      opts.silent = true
    end
  end
end

function S.mapping(o)
  local mode = table.remove(o, 1)
  with_default_opts(mode, o)
  o.mode = mode
  return o
end

function S.map_buf(bufnr, mode, l, r, opts)
  local opts = opts or {}
  with_default_opts(mode, opts)
  opts.buffer = bufnr
  vim.keymap.set(mode, l, r, opts)
end

function S.map(mode, l, r, opts)
  local opts = opts or {}
  with_default_opts(mode, opts)
  vim.keymap.set(mode, l, r, opts)
end

return S
