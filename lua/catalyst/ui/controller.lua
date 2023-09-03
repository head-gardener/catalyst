local cm = require('catalyst.ui.copmonents')
local st = require('catalyst.state')

local M = {}

local function ui_spawner(state)
  return coroutine.create(function()
    cm.picker(state)
    cm.edit_dialogue(state)
    cm.persist_dialogue(state)
  end)
end

local function controller(state)
  return coroutine.create(function()
    local spawner = ui_spawner(state)
    while coroutine.status(spawner) ~= "dead" do
      local ok, obj, post = coroutine.resume(spawner)
      if not ok then
        print(obj)
        error()
      else
        obj:mount()
        if post ~= nil then
          post()
        end
      end
      state.ctl:yield()
    end
    print('exit')
  end)
end

function M.pick(state)
  local thr = controller(state)
  st.ui_ctl.start(state, thr)
end

return M
