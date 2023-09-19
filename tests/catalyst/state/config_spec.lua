local cf = require('catalyst.state.config')

local opts = {
  presets =
  { sample = { run = 'run', build = 'build', test = 'test' } },
}
local opts_extr = {
  opts.presets,
  functions = {
    { 'watch' }
  },
}

describe('config manager', function()
  it('can be created from an empty opts table', function()
    assert.is_not._nil(cf.setup({}))
  end)

  it('can prettify any config', function()
    assert.is_are.same(3, #cf.prettify({ run = '', build = '', test = '' }))

    assert.is_are.same(4, #cf.prettify({ run = '', build = '', test = '', watch = '' }))
    assert.matches('watch. ', cf.prettify({ run = '', build = '', test = '', watch = '' })[4])
  end)

  describe('validator', function()
    local config
    local config_opt

    before_each(function()
      config = cf.setup(opts)
      config_opt = cf.setup(opts_extr)
    end)

    it('can check presets', function()
      assert.is_true(config:valid(
        { run = 'run', build = 'build', test = 'test', }))
      assert.is_true(config_opt:valid(
        { run = 'run', build = 'build', test = 'test', watch = 'watch' }))

      assert.is_false(config:valid('hey'))
      assert.is_false(config:valid({}))
      assert.is_false(config:valid({ run = 1 }))
      assert.is_false(config_opt:valid(
        { run = 'run', build = 'build', test = 'test', watch = 1 }))
    end)

    it('can check tables of presets', function()
      assert.is_true(config:valid_all({
        a = { run = 'run', build = 'build', test = 'test', },
        b = { run = 'run', build = 'build', test = 'test', },
      }))

      local s, r = config:valid_all()
      assert.is_false(s)
      assert.is_nil(r)

      local s, r = config:valid_all({
        a = { run = 'run', build = 'build', test = 'test', },
        b = {},
      })
      assert.is_false(s)
      assert.are.same(r, 'b')
    end)
  end)
end)
