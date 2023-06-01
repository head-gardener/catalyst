local M = {}

function M.new(opts)
  local ps = { make = { run = "build/bin", build = "make build", test = "make check" } }
  if opts.presets then ps = opts.presets end
  local p = next(ps, nil)
  return { presets = ps, preset = p }
end

function M.prettify(a)
  return { "run: " .. a.run, "build: " .. a.build, "test: " .. a.test }
end

M.preset = "cabal"

function M.get(state)
  return state.presets[state.preset]
end

function M.set(state, x)
  state.preset = x
end

return M
