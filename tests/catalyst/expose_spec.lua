local expose = require('catalyst.expose')

describe('expose function', function()
  it('can parse compete function list', function()
    local keymaps = {}
    vim.keymap.set = function(_, key)
      keymaps[key] = true
    end


    M = {}
    expose(M, {
      functions = {
        { 'run',   'run' },
        { 'test', },
        { 'build', 'build' },
        { 'pick',  'pick' },
        { 'edit', },
        { 'watch', 'watch' },
      }
    }, {})

    assert.is.Function(M.run)
    assert.is.Function(M.watch)

    assert.is.True(keymaps.run)
    assert.is.True(keymaps.build)
    assert.is.True(keymaps.pick)
    assert.is.True(keymaps.watch)
    assert.is.Nil(keymaps.test)
    assert.is.Nil(keymaps.edit)
  end)

  it('always adds default functions', function()
    expose(M, {}, {})

    assert.is.Function(M.run)
    assert.is.Function(M.build)
    assert.is.Function(M.test)
    assert.is.Function(M.edit)
    assert.is.Function(M.pick)
  end)
end)
