local ui = require("catalyst.ui")
local iron = require("iron.core")

return function(M, opts, state)
  function M.pick()
    ui.pick(state)
  end

  function M.edit()
    ui.edit(state)
  end

  if not opts.keymaps then return end

  for k, v in pairs(opts.keymaps) do
    -- generate missing calls to config commands
    if not M[k] then
      M[k] = function()
        iron.send('fish', state.config:system()[k])
      end
    end

    if v ~= '' then
      vim.keymap.set('n', v, M[k], { remap = false })
    end
    vim.api.nvim_create_user_command('Catl' .. (k:gsub("^%l", string.upper)),
      M[k],
      { nargs = '?' })
  end
end
