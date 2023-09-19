local cf = require('catalyst.state.config')

local M = {}

-- might want to replace this with sqlite if performance tanks too much
-- until then simplicity should be way more important

local function cfg_path()
  return vim.fn.stdpath('data') .. '/catalyst.json'
end

--- Read persistent storage.
-- Returns true, cfg if config is valid,
-- false, err otherwise
local function read()
  local path = cfg_path()
  local storage = io.open(path, 'r')
  if storage == nil then
    return true, {}
  end
  local data = storage:read()
  storage:close()

  return pcall(vim.fn.json_decode, data)
end

local function write(pers_conf)
  local path = cfg_path()
  local storage = io.open(path, 'w')
  if storage == nil then
    print("Can't open " .. path)
    return
  end

  storage:write(vim.fn.json_encode(pers_conf))
  print("Updated catalyst configuration at " .. path)
  storage:close()
end

--- Mutate persistent storage.
-- @param f function that mutates `cfg` passed.
local function update(f)
  local ok, cfg = read()
  if not ok then
    error(
      'Fix storage file before attempting to write to it. Error: '
      .. cfg)
  end
  f(cfg)
  write(cfg)
end

--- Attempts to persist configuration, associating it with pwd.
function M.persist(config)
  update(function(cfg)
    cfg[vim.fn.getcwd()] = { build_system = config:system() }
  end)
end

function M.sync(state)
  local s, conf = read()
  if not s or not conf then
    error('malformed storage file: ' .. conf)
  end

  local pers_conf = conf[vim.fn.getcwd()]
  if not pers_conf then return end

  if not state.config:valid(pers_conf.build_system) then
    error('malformed config stored for ' .. vim.fn.getcwd())
  else
    state.config:set(pers_conf.build_system)
  end
end

return M
