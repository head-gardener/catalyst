local ui = require("catalyst.ui")
local iron = require("iron.core")

return function(M, opts, state)
  local shell = opts.shell or 'bash'

  -- defaults
  function M.pick() ui.pick(state) end

  function M.edit() ui.edit(state) end

  function M.run() iron.send(shell, state.config:system().run) end

  function M.build() iron.send(shell, state.config:system().build) end

  function M.test() iron.send(shell, state.config:system().test) end

  if not opts.functions then return end

  for _, v in pairs(opts.functions) do
    -- schema
    local f = v[1]
    local k = v[2]

    -- generate missing calls to config commands
    if not M[f] then
      M[f] = function()
        local s = state.config:system()
        if not s[f] then return end
        iron.send(shell, s[f])
      end
    end

    if type(k) == 'string' then
      vim.keymap.set('n', k, M[f], { remap = false })
    end
    vim.api.nvim_create_user_command('Catl' .. (f:gsub("^%l", string.upper)),
      M[f],
      { nargs = '?' })
  end
end
