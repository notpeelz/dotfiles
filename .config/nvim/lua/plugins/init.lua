local files = vim.fn.glob(
  vim.fn.stdpath("config") .. "/lua/plugins/*.lua",
  false,
  true
)
for _, file in ipairs(files) do
  local name = vim.fn.fnamemodify(file, ":t:r")
  if name ~= "init" then
    require("plugins." .. name)
  end
end
