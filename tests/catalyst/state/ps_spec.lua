local ps = require('catalyst.state.ps')
local spy = require('luassert.stub')
local match = require('luassert.match')

describe('persistant storage manager', function()
  it('handles completely invalid input', function()
    local closed = false

    io.open = function()
      closed = false
      return {
        read = function()
          return '///./'
        end,
        close = function()
          assert.is_false(closed)
          closed = true
        end,
      }
    end

    assert.errors(ps.sync)
    assert.is_true(closed)
  end)

  it('handles invalid fields in the input', function()
    vim.fn.getcwd = function() return 'a' end

    io.open = function()
      return {
        read = function()
          return vim.fn.json_encode({ a = {} })
        end,
        close = function() end,
      }
    end

    assert.errors(ps.sync)
  end)
end)
