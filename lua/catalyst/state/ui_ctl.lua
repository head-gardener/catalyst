local M = {}

function M.start(state, thr)
  local ctl = { thr = thr }

  function ctl:resume()
    coroutine.resume(self.thr)
  end

  function ctl:yield()
    coroutine.yield()
  end

  state.ctl = ctl
end

return M
