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
  local optional = {}

  function this:presets()
    return self.ps
  end

  function this:system()
    return self.sys
  end

  function this:wrap(wrapper)
    local a = {}
    local b = {}

    a[1], b[1] = wrapper('run', self:system().run)
    a[2], b[2] = wrapper('build', self:system().build)
    a[3], b[3] = wrapper('test', self:system().test)

    return a, b
  end

  function this:set(new)
    self.sys = new
  end

  function this:edit(new)
    local changed = false

    if new.run ~= nil and new.run ~= self.sys.run then
      self.sys.run = new.run
      changed = true
    end
    if new.build ~= nil and new.build ~= self.sys.build then
      self.sys.build = new.build
      changed = true
    end
    if new.test ~= nil and new.test ~= self.sys.test then
      self.sys.test = new.test
      changed = true
    end

    return changed
  end

  function this:valid(a)
    if type(a) ~= 'table' then return false end
    for _, v in pairs(self.optional) do
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

  local opt = {}
  for _, v in pairs(opts.functions) do
    local f = v[1]
    if not DEFAULT_COMMAND[f] then
      table.insert(opt, f)
    end
  end

  this.ps = ps
  this.sys = sys
  this.optional = opt

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
