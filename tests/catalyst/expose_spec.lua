local DEFAULT_COMMAND = require('catalyst.state.config').DEFAULT_COMMAND
local expose = require('catalyst.expose')

describe('expose function', function()
  local keymaps = {}
  local commands = {}

  vim.api.nvim_create_user_command = function(a, _, _)
    commands[a] = true
  end
  vim.keymap.set = function(_, key)
    keymaps[key] = true
  end

  before_each(function()
    commands = {}
    keymaps = {}
  end)

  it('can parse compete function list', function()
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

    for k, _ in pairs(DEFAULT_COMMAND) do
      assert.is.Function(M[k], k .. ' func missing')
      assert.is.True(commands['Catl' .. (k:gsub("^%l", string.upper))], k .. ' cmd missing')
      assert.is.Nil(keymaps[k], k .. ' keymap')
    end
  end)
end)
