local ss = require('catalyst.state.session')
local cf = require('catalyst.state.config')
local ps = require('catalyst.state.ps')
local mock = require('luassert.mock')

mock(ps, true)

local opts = {
  presets = {
    make = { run = "build/bin", build = "make build", test = "make check" },
    sample = { run = "run", build = "build", test = "test" },
  },
}

describe('session storage', function()
  describe('object', function()
    local session = ss.setup(opts)

    it('re-exposes simple config getters correctly', function()
      local c = cf.setup(opts)

      assert.is_not._nil(session.config.presets)
      assert.is_not._nil(session.config:presets())
      assert.is_not._nil(session.config.system)
      assert.is_not._nil(session.config:system())

      assert.are.same(c:presets(), session.config:presets())
      assert.are.same(c:system(), session.config:system())

      c:set(c:presets().sample)
      session.config:set(session.config:presets().sample)
      assert.are.same(c:system(), session.config:system())
      c:set(c:presets().make)
      session.config:set(session.config:presets().make)
      assert.are.same(c:system(), session.config:system())
    end)

    it('re-exposes functions with args from config correctly', function()
      local c = cf.setup(opts)
      local f = function(a, b)
        return "a " .. a, "b " .. b
      end

      assert.are.same(c:wrap(f), session.config:wrap(f))
    end)

    it('re-exposes all ps functions', function()
      for k, v in pairs(ps) do
        if type(v) == "function" then
          assert.is_not._nil(session.ps[k])
        end
      end
    end)
  end)

  describe('logic', function()
    local session

    before_each(function()
      session = ss.setup(opts)
    end)

    it('updates on config changes', function()
      assert.is._false(session:is_dirty())
      session.config:set(session.config:presets().sample)
      assert.is._true(session:is_dirty())

      session:clear()
      assert.is._false(session:is_dirty())
      session.config:edit(session.config:presets().make)
      assert.is._true(session:is_dirty())
    end)

    it('clears after ps calls', function()
      session:mark()
      assert.is._true(session:is_dirty())
      session.ps.sync()
      assert.is._false(session:is_dirty())

      session:mark()
      assert.is._true(session:is_dirty())
      session.ps.persist()
      assert.is._false(session:is_dirty())
    end)

    it('keep_clean works', function()
      session:mark()
      session:keep_clean()
      assert.is._false(session:is_dirty())

      session.config:set(session.config:presets().sample)
      assert.is._false(session:is_dirty())
    end)
  end)
end)
