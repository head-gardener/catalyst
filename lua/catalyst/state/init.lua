local M = {}

-- fields
local ss = require('catalyst.state.session')
local ct = require('catalyst.state.ui_ctl')

-- functional modules
M.picker = require('catalyst.state.picker')

-- re-exposed functions
M.prettify = require('catalyst.state.config').prettify

function M.setup(opts)
  local s = ss.setup(opts)
  return {
    config = s.config,
    ps = s.ps,
    session = s,
    ui_ctl = ct.setup(),
  }
end

return M
