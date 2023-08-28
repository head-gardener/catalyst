local M = {}

-- might want to replace this with sqlite if performance tanks too much
-- until then simplicity should be way more important

DEFAULT_PRESETS = { make = { run = "build/bin", build = "make build", test = "make check" } }

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
  print("Updated catalyst configuration at " .. path)
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
  if opts == nil then opts = {} end

  local ps
  if opts.presets then ps = opts.presets else ps = DEFAULT_PRESETS end

  local p = next(ps, nil)
  local cfg = nil
  if p ~= nil then cfg = ps[p] end

  return { presets = ps, preset = p, cfg = cfg }
end

function M.sync(state)
  local cfg = read()[vim.fn.getcwd()]
  if cfg ~= nil then
    state.cfg = cfg.build_system
  end
end

function M.wrap(wrapper, state)
  local a = {}
  local b = {}
  local on_write = function(cfg)
    M.edit(state, cfg)
  end

  a[1], b[1] = wrapper("run", M.current(state).run, on_write)
  a[2], b[2] = wrapper("build", M.current(state).build, on_write)
  a[3], b[3] = wrapper("test", M.current(state).test, on_write)

  return a, b
end

function M.prettify(a)
  return { "run: " .. a.run, "build: " .. a.build, "test: " .. a.test }
end

M.selected = "make"

function M.selected(state)
  return state.presets[state.preset]
end

function M.select(state, x)
  state.preset = x
end

function M.edit(state, cfg)
  if cfg.run ~= nil then
    state.cfg.run = cfg.run
  end
  if cfg.build ~= nil then
    state.cfg.build = cfg.build
  end
  if cfg.test ~= nil then
    state.cfg.test = cfg.test
  end
end

function M.current(state)
  return state.cfg
end

function M.confirm(state)
  state.cfg = M.selected(state)
end

return M
