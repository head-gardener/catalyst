local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local cf = require("catalyst.config")

local M = {}

local function make_pair(a, b, on_write)
  local a_popup = Popup({
    focusable = false,
    buf_options = {
      modifiable = false,
      readonly = true,
    },
    win_options = {
      winhighlight = "Normal:StatusLine",
    },
    border = {
      padding = { 0, 2 },
    },
  })

  -- :set singleline
  local b_popup =
      Popup({
        enter = true,
        border = {
          style = "solid",
          padding = { 0, 0 },
        },
      })

  vim.api.nvim_buf_set_lines(a_popup.bufnr, 2, 3, false, { a })
  vim.api.nvim_buf_set_lines(b_popup.bufnr, 0, -1, false, { b })

  b_popup:on("BufLeave", function()
    -- will only pull one liners
    local cmd = vim.api.nvim_buf_get_lines(b_popup.bufnr, 0, 1, false)[1]
    local cfg = {}
    cfg[a] = cmd
    on_write(cfg)
  end)

  return a_popup, b_popup
end

local function wrap_cfg(state)
  local a, b = cf.wrap(make_pair, state)

  -- is this correct?
  b[1]:on({ "BufUnload" }, function()
    coroutine.resume(state.ctrl)
  end)

  local a_bs = {}
  local b_bs = {}
  for i = 1, #a do
    a_bs[i] = Layout.Box(a[i], { grow = 1 })
    b_bs[i] = Layout.Box(b[i], { grow = 1 })
  end

  local p = Layout(
    {
      relative = "editor",
      position = "50%",
      grow = 2,
      size = {
        width = 80,
        height = 10,
      },
    },
    Layout.Box({
      Layout.Box(a_bs, { dir = "col", size = 13 }),
      Layout.Box(b_bs, { dir = "col", grow = 1 }),
    }, { dir = "row" })
  )

  return p, function()
    -- setup window navigation.
    -- should be post-mount since winid is
    -- unavailable until buffer is mounted.

    -- b[i].winid doesn't survive till the callback
    -- and should be saved separately
    local ids = {}
    for i = 1, #b do
      ids[i] = b[i].winid
    end

    for i = 1, #b - 1 do
      b[i]:map("n", "j", function(_)
        vim.schedule(function()
          vim.api.nvim_set_current_win(ids[i + 1])
        end)
      end, { noremap = true })
    end

    for i = 2, #b do
      b[i]:map("n", "k", function(_)
        vim.schedule(function()
          vim.api.nvim_set_current_win(ids[i - 1])
        end)
      end, { noremap = true })
    end

    -- local bid2 = b[2].winid
    -- print(bid2)
  end
end

local function editor(state)
  local this, post = wrap_cfg(state)

  coroutine.yield(this, post)
end

local function edit_dialogue(state)
  local user_input =
      vim.fn.confirm("Edit commands?", "&Yes\n&No", 2)

  if user_input == 1 then
    editor(state)
  end
end

local function persist_dialogue(state)
  local user_input =
      vim.fn.confirm("Remember choice for current directory?", "&Yes\n&No", 2)

  if user_input == 1 then
    cf.persist(cf.current(state))
  end
end

local function picker(state)
  local function selected_display()
    local this =
        Popup({
          enter = false,
          border = {
            style = "single",
            padding = { 0, 2 },
            text = {
              top = "-Selected-",
              top_align = "center",
            },
          },
        })
    return
        this,
        function(config)
          vim.api.nvim_buf_set_lines(this.bufnr, 0, -1, false, cf.prettify(cf.selected(config)))
        end
  end

  local function current_display(c)
    local this =
        Popup({
          enter = false,
          border = {
            style = "single",
            padding = { 0, 2 },
            text = {
              top = "-Current-",
              top_align = "center",
            },
          },
        })

    vim.api.nvim_buf_set_lines(this.bufnr, 0, -1, false, cf.prettify(cf.current(c)))
    return this
  end

  local function picker_menu(c, lines, upd_sel)
    local menu = Menu({
      position = "50%",
      size = {
        width = 25,
        height = 5,
      },
      border = {
        style = "single",
      },
      win_options = {
        winhighlight = "Normal:Normal,FloatBorder:Normal",
      },
    }, {
      lines = lines,
      max_width = 20,
      keymap = {
        focus_next = { "j", "<Down>", "<Tab>" },
        focus_prev = { "k", "<Up>", "<S-Tab>" },
        close = { "<Esc>", "<C-c>" },
        submit = { "<CR>", "<Space>" },
      },
      on_change = function(item)
        cf.select(c, item.text)
        upd_sel(c)
      end,
      on_submit = function()
        cf.confirm(c)
        coroutine.resume(state.ctrl)
      end,
    })

    return menu
  end

  local lines = {}
  for key, _ in pairs(state.presets) do
    table.insert(lines, Menu.item(key))
  end

  local s, upd = selected_display()
  local c = current_display(state)
  local m = picker_menu(state, lines, upd)

  local p = Layout(
    {
      relative = "editor",
      position = "50%",
      grow = 2,
      size = {
        width = 80,
        height = 14,
      },
    },
    Layout.Box({
      Layout.Box(m, { size = { width = 15 } }),
      Layout.Box({
        Layout.Box(s, { size = "50%" }),
        Layout.Box(c, { size = "50%" }),
      }, { dir = "col", grow = 1 }),
    }, { dir = "row" })
  )

  -- TODO: unmount on losing focus

  coroutine.yield(p)
end

local function ui_spawner(state)
  return coroutine.create(function()
    picker(state)
    edit_dialogue(state)
    persist_dialogue(state)
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
      coroutine.yield()
    end
    print('exit')
  end)
end

function M.pick(state)
  state.ctrl = controller(state)
  coroutine.resume(state.ctrl)
end

return M
