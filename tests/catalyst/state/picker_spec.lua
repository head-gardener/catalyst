local pp = require('catalyst.state.picker')
local spy = require('luassert.stub')
local match = require('luassert.match')

local presets = { make = 'make', cargo = 'cargo' }

describe('picker state object', function()
  local picker

  before_each(function()
    picker = pp.setup(presets)
  end)

  it('selects', function()
    picker:select('make')
    assert.are.same(picker.selected(), 'make')
    picker:select('cargo')
    assert.are.same(picker.selected(), 'cargo')
  end)

  it('sets', function()
    local cf = {
      set = spy.new()
    }

    picker:select('make')
    picker:confirm(cf)

    assert.spy(cf.set).was.called(1)
    assert.spy(cf.set).was.called_with(match._, 'make')
  end)
end)
