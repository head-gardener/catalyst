local M = {}

function M.setup()
  local this = {}

  function this:start(thr)
    self.thr = thr
    self:resume()
  end

  function this:resume()
    coroutine.resume(self.thr)
  end

  -- function this:finish()

  function this:yield()
    coroutine.yield()
  end

  return this
end

return M
