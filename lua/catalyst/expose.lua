local ui = require("catalyst.ui")
local DEFAULT_COMMAND = require('catalyst.state.config').DEFAULT_COMMAND
local iron = require("iron.core")

-- `a` should be ASCII lowercase
local function makecmd(a, f)
  vim.api.nvim_create_user_command(
    'Catl' .. (a:gsub("^%l", string.upper)),
    f,
    { nargs = '?' })
end

return function(M, opts, state)
  local shell = opts.shell or 'bash'

  -- defaults
  function M.pick() ui.pick(state) end

  function M.edit() ui.edit(state) end

  function M.run() iron.send(shell, state.config:system().run) end

  function M.build() iron.send(shell, state.config:system().build) end

  function M.test() iron.send(shell, state.config:system().test) end

  for k, _ in pairs(DEFAULT_COMMAND) do
    makecmd(k, M[k])
  end

  if not opts.functions then return end
  for _, v in pairs(opts.functions) do
    -- schema
    local f = v[1]
    local k = v[2]

    -- generate missing functions and commands
    if not DEFAULT_COMMAND[f] then
      M[f] = function()
        local s = state.config:system()
        if not s[f] then return end
        iron.send(shell, s[f])
      end

      makecmd(f, M[f])
    end

    if type(k) == 'string' then
      vim.keymap.set('n', k, M[f], { remap = false })
    end
  end
end
