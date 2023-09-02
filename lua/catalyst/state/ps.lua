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
  local cfg = read()
  f(cfg)
  write(cfg)
end

--- Attempts to persist configuration, associating it with pwd.
function M.persist(config)
  update(function(cfg)
    cfg[vim.fn.getcwd()] = { build_system = config:system() }
  end)
end

function M.sync(config)
  local pers_conf = read()[vim.fn.getcwd()]
  if pers_conf ~= nil then
    config:set(pers_conf.build_system)
  end
end

return M
