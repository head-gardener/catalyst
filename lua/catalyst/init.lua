local st = require('catalyst.state')
local expose = require('catalyst.expose')

local M = {}

local function setup(opts)
  if opts == nil then opts = {} end
  local state = st.setup(opts)

  expose(M, opts, state)

  vim.api.nvim_create_autocmd('DirChanged', {
    callback = function()
      state.ps.sync(state)
    end,
  })
  state.ps.sync(state)
end

M.setup = setup
return M
