local ct = require('catalyst.ui.controller')
local cm = require('catalyst.ui.components')
local st = require('catalyst.state')

describe('ui controller', function()
  local state

  before_each(function()
    state = st.setup({})
  end)

  it('propagates errors from components', function()
    local f = cm.picker
    cm.picker = function()
      error('bad error')
    end

    assert.error_matches(function() ct.pick(state) end, 'bad error$')
    assert.is_false(state.ui_ctl:up())

    cm.picker = f
  end)

  it('can run all dialogues', function()
    for k, v in pairs(ct) do
      if type(v) ~= "function" then
        goto continue
      end

      ct[k](state)
      while state.ui_ctl:up() do
        state.ui_ctl:resume()
      end

      ::continue::
    end
  end)
end)
