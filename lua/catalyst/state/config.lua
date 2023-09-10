local M = {}

DEFAULT_PRESETS = { make = { run = "build/bin", build = "make build", test = "make check" } }

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

    a[1], b[1] = wrapper("run", self:system().run)
    a[2], b[2] = wrapper("build", self:system().build)
    a[3], b[3] = wrapper("test", self:system().test)

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

  if opts == nil then opts = {} end

  local ps
  if opts.presets then ps = opts.presets else ps = DEFAULT_PRESETS end

  local p = next(ps, nil)
  local sys = nil
  if p ~= nil then sys = ps[p] end

  this.ps = ps
  this.sys = sys

  return this
end

function M.prettify(a)
  return { "run: " .. a.run, "build: " .. a.build, "test: " .. a.test }
end

function M.validate(a)
  return
      type(a) == "table" and
      type(a.run) == "string" and
      type(a.build) == "string" and
      type(a.test) == "string"
end

function M.validate_all(a)
  if not a then return false end

  for k, v in pairs(a) do
    if not M.validate(v) then
      return false, k
    end
  end

  return true
end

return M
