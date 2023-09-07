local cf = require('catalyst.state.config')

local opts = {
  presets =
  { sample = { run = "run", build = "build", test = "test" } }
}

describe('config manager', function()
  local config

  before_each(function()
    config = cf.setup(opts)
  end)

  it('can be created from an empty opts table', function()
    assert.is_not._nil(cf.setup({}))
  end)
end)
