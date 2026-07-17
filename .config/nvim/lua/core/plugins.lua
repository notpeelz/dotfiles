local plugin = require("core.plugin")

return function(specs)
  for _, spec in ipairs(specs) do
    plugin(spec)
  end
end
