local cm = require('catalyst.ui.components')

local M = {}

local function edit_spawner(state)
  return coroutine.create(function()
    cm.editor(state)
    cm.persist_dialogue(state)
  end)
end

local function pick_spawner(state)
  return coroutine.create(function()
    cm.picker(state)
    cm.edit_dialogue(state)
    cm.persist_dialogue(state)
  end)
end

local function controller(state, entry)
  return coroutine.create(function()
    local spawner
    if entry == 'pick' then
      spawner = pick_spawner(state)
    elseif entry == 'edit' then
      spawner = edit_spawner(state)
    end

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
      state.ui_ctl:yield()
    end
  end)
end

function M.pick(state)
  local thr = controller(state, "pick")
  state.ui_ctl:start(thr)
end

function M.edit(state)
  local thr = controller(state, "edit")
  state.ui_ctl:start(thr)
end

return M
