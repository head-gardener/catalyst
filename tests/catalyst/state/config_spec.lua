local cf = require('catalyst.state.config')

local opts = {
  presets =
  { sample = { run = 'run', build = 'build', test = 'test' } }
}

describe('config manager', function()
  local config

  before_each(function()
    config = cf.setup(opts)
  end)

  it('can be created from an empty opts table', function()
    assert.is_not._nil(cf.setup({}))
  end)

  describe('validator', function()
    it('can check presets', function()
      assert.is_true(cf.validate(
        { run = 'run', build = 'build', test = 'test', }))

      assert.is_false(cf.validate('hey'))
      assert.is_false(cf.validate({}))
      assert.is_false(cf.validate({ run = 1 }))
    end)

    it('can check tables of presets', function()
      assert.is_true(cf.validate_all({
        a = { run = 'run', build = 'build', test = 'test', },
        b = { run = 'run', build = 'build', test = 'test', },
      }))

      local s, r = cf.validate_all()
      assert.is_false(s)
      assert.is_nil(r)

      local s, r = cf.validate_all({
        a = { run = 'run', build = 'build', test = 'test', },
        b = {},
      })
      assert.is_false(s)
      assert.are.same(r, 'b')
    end)
  end)
end)
