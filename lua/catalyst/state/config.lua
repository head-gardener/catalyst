local M = {}

DEFAULT_PRESETS = { make = { run = 'build/bin', build = 'make build', test = 'make check' } }
DEFAULT_COMMAND = {
  run = true,
  build = true,
  test = true,
  pick = true,
  edit = true,
}

function M.setup(opts)
  local this = {}

  function this:presets()
    return self.ps
  end

  function this:system()
    return self.sys
  end

  function this:wrap(wrapper)
    local a = {}
    local b = {}
    local s = self:system()
    if not s then error('config is nil') end

    for _, v in pairs(self.cmds) do
      local ai, bi = wrapper(v, s[v] or '')
      table.insert(a, ai)
      table.insert(b, bi)
    end

    return a, b
  end

  function this:set(new)
    self.sys = new
  end

  function this:edit(new)
    local changed = false

    for _, v in pairs(self.cmds) do
      if
          new[v] == nil or
          new[v] == '' and self.sys[v] == nil
      then
        goto continue
      end

      if new[v] == '' and not DEFAULT_COMMAND[v] and self.sys[v] ~= nil then
        -- delete opt cmd with empty string
        self.sys[v] = nil
        changed = true
      elseif new[v] ~= self.sys[v] then
        self.sys[v] = new[v]
        changed = true
      end

      ::continue::
    end

    return changed
  end

  function this:valid(a)
    -- PERF: this could be done better, especially knowing that
    -- validation is mostly ran on startup

    if type(a) ~= 'table' then return false end
    for _, v in pairs(self.cmds) do
      if type(a[v]) ~= 'nil' and type(a[v]) ~= 'string' then
        return false
      end
    end

    return
        type(a.run) == 'string' and
        type(a.build) == 'string' and
        type(a.test) == 'string'
  end

  function this:valid_all(a)
    if not a then return false end

    for k, v in pairs(a) do
      if not self:valid(v) then
        return false, k
      end
    end

    return true
  end

  if opts.functions == nil then opts.functions = {} end

  local ps = opts.presets or DEFAULT_PRESETS
  if ps == {} then ps.make = DEFAULT_PRESETS.make end

  local p = next(ps, nil)
  local sys = nil
  if p ~= nil then sys = ps[p] end

  -- commands should be in a specific order
  local cmds = { 'run', 'build', 'test' }
  for _, v in pairs(opts.functions) do
    local f = v[1]
    if not DEFAULT_COMMAND[f] then
      table.insert(cmds, f)
    end
  end

  this.ps = ps
  this.sys = sys
  this.cmds = cmds

  return this
end

function M.prettify(a)
  local r = { 'run: ' .. a.run, 'build: ' .. a.build, 'test: ' .. a.test }

  for k, v in pairs(a) do
    if not DEFAULT_COMMAND[k] then
      table.insert(r, k .. ': ' .. v)
    end
  end

  return r
end

return M
