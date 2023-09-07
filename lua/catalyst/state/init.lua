local M = {}

-- fields
local ss = require('catalyst.state.session')

-- functional modules
M.ps = require('catalyst.state.ps')
M.picker = require('catalyst.state.picker')
M.ui_ctl = require('catalyst.state.ui_ctl')

-- re-exposed functions
M.prettify = require('catalyst.state.config').prettify

function M.setup(opts)
  local s = ss.setup(opts)
  return {
    config = s.config,
    ps = s.ps,
    session = s,
  }
end

return M
