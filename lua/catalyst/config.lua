local M = {}

-- might want to replace this with sqlite if performance tanks too much
-- until then simplicity should be way more important

local function cfg_path()
  return vim.fn.stdpath('data') .. '/catalyst.json'
end

local function read()
  local path = cfg_path()
  local storage = io.open(path, 'r')
  if storage == nil then
    return {}
  end
  local data = storage:read()
  local cfg = vim.fn.json_decode(data)
  storage:close()

  return cfg
end

local function write(cfg)
  local path = cfg_path()
  local storage = io.open(path, 'w')
  if storage == nil then
    print("Can't open " .. path)
    return
  end

  storage:write(vim.fn.json_encode(cfg))
  print("Updated catalyst configuration")
  storage:close()
end

--- Mutate persistent storage.
-- @param f function that mutates `cfg` passed.
local function update(f)
  local cfg = read()
  f(cfg)
  write(cfg)
end

--- Attempts to persist configuration, associating it with pwd.
-- @param conf configuration, as defined by this file.
function M.persist(conf)
  update(function(cfg)
    cfg[vim.fn.getcwd()] = { build_system = conf }
  end)
end

function M.new(opts)
  local ps = { make = { run = "build/bin", build = "make build", test = "make check" } }
  if opts.presets then ps = opts.presets end


  local p = next(ps, nil)
  local b_sys = nil
  if p ~= nil then b_sys = ps[p] end

  return { presets = ps, preset = p, b_sys = b_sys }
end

function M.sync(state)
  local cfg = read()[vim.fn.getcwd()]
  if cfg ~= nil then
    state.b_sys = cfg.build_system
  end
end

function M.prettify(a)
  return { "run: " .. a.run, "build: " .. a.build, "test: " .. a.test }
end

M.preset = "cabal"

function M.preset(state)
  return state.presets[state.preset]
end

function M.select(state, x)
  state.preset = x
end

function M.get(state)
  return state.b_sys
end

function M.confirm(state)
  state.b_sys = M.preset(state)
  print(vim.inspect(M.get(state).run))
end

return M
