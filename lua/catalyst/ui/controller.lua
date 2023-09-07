local cm = require('catalyst.ui.copmonents')
local st = require('catalyst.state')

local M = {}

local function ui_spawner(state, entry)
  return coroutine.create(function()
    if entry == "pick" then
      cm.picker(state)
    end

    if entry ~= "edit" then
      cm.edit_dialogue(state)
    else
      cm.editor(state)
    end

    cm.persist_dialogue(state)
  end)
end

local function controller(state, entry)
  return coroutine.create(function()
    local spawner = ui_spawner(state, entry)
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
  local thr = controller(state, "pick")
  st.ui_ctl.start(state, thr)
end

function M.edit(state)
  local thr = controller(state, "edit")
  st.ui_ctl.start(state, thr)
end

return M
