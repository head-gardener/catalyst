local M = {}

M.selected = "make"

function M.selected(state)
  return state.presets[state.preset]
end

function M.select(state, x)
  state.preset = x
end

function M.confirm(state)
  state.cfg = M.selected(state)
end

return M
