return function(env)
  local mjomatic

  for k,v in pairs(env) do _G[k] = v end

  mjomatic = require('init')

  return mjomatic
end
