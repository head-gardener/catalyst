local cf = require('catalyst.state.config')
local ps = require('catalyst.state.ps')

local M = {}

function M.setup(opts)
  local this = {
    dirty = false,
    keep_clean_flag = false,
  }

  function this:is_dirty()
    return self.dirty
  end

  function this:mark()
    if self.keep_clean_flag then return end
    self.dirty = true
  end

  function this:clear()
    self.dirty = false
  end

  function this:keep_clean()
    self.keep_clean_flag = true
    this:clear()
  end

  local c = cf.setup(opts)
  local wrap = { _orig = c }

  function wrap:set(x)
    wrap._orig:set(x)
    this:mark()
  end

  function wrap:edit(x)
    if wrap._orig:edit(x) then
      this:mark()
    end
  end

  -- a hack but should work for now
  for k, v in pairs(wrap._orig) do
    if type(v) == "function" and wrap[k] == nil then
      wrap[k] = function(self, ...)
        return self._orig[k](self._orig, ...)
      end
    end
  end

  local p = {}
  function p.sync(config)
    ps.sync(config)
    this:clear()
  end

  function p.persist(config)
    ps.persist(config)
    this:clear()
  end

  this.ps = p
  this.config = wrap

  return this
end

return M
