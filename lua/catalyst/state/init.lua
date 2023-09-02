local M = {}

-- fields
local cf = require('catalyst.state.config')

-- functional modules
M.ps = require('catalyst.state.ps')
M.picker = require('catalyst.state.picker')
M.ui_ctl = require('catalyst.state.ui_ctl')

-- re-exposed functions
M.prettify = require('catalyst.state.config').prettify

function M.setup(opts)
  return {
    config = cf.setup(opts),
  }
end

return M
