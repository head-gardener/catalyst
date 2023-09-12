local M = {}

function M.setup()
  local this = {}

  function this:start(thr)
    self.thr = thr
    self:resume()
  end

  -- one day I really should ponder a bit on how exactly does this work
  function this:resume()
    local ok, err = coroutine.resume(self.thr)
    if not ok then
      self.thr = nil
      error(err, 3)
    end
  end

  function this:up()
    return
        type(self.thr) == "thread" and
        coroutine.status(self.thr) ~= "dead"
  end

  function this:yield()
    coroutine.yield()
  end

  return this
end

return M
