local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local st = require("catalyst.state")

-- All UI components should be represented by an exposed function,
-- that yields NUI component and a post-mount callback, both can
-- be nil when not needed.
-- Might change this to returning instead of yielding and wrap all
-- the functions if the need arises.

local M = {}

local function make_pair(a, b)
  local a_popup = Popup({
    focusable = false,
    buf_options = {
      modifiable = false,
      readonly = true,
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
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
        win_options = {
          winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
        },
      })

  b_popup.config_entry = a

  vim.api.nvim_buf_set_lines(a_popup.bufnr, 2, 3, false, { a })
  vim.api.nvim_buf_set_lines(b_popup.bufnr, 0, -1, false, { b })

  return a_popup, b_popup
end

local function wrap_cfg(state)
  local a, b = state.config:wrap(make_pair)

  -- is this correct?
  b[1]:on({ "BufUnload" }, function()
    state.ui_ctl:resume()
  end)

  for _, v in pairs(b) do
    v:on("BufLeave", function()
      -- will only pull one liners
      local cmd = vim.api.nvim_buf_get_lines(v.bufnr, 0, 1, false)[1]
      local cfg = {}
      cfg[v.config_entry] = cmd
      state.config:edit(cfg)
    end)
  end

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

function M.editor(state)
  local this, post = wrap_cfg(state)

  coroutine.yield(this, post)
end

function M.edit_dialogue(state)
  local user_input =
      vim.fn.confirm("Edit commands?", "&Yes\n&No", 2)

  if user_input == 1 then
    M.editor(state)
  end
end

function M.persist_dialogue(state)
  if not state.session:is_dirty() then return end

  local user_input =
      vim.fn.confirm("Remember choice for current directory?", "&Yes\n&No\nN&ever", 2)

  if user_input == 1 then
    state.ps.persist(state.config)
  elseif user_input == 3 then
    state.session:keep_clean()
    print('You won\'t be prompted to persist config choice until the plugin is reloaded.')
  end

  coroutine.yield()
end

function M.picker(state)
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
        function(pp)
          vim.api.nvim_buf_set_lines(this.bufnr, 0, -1, false, st.prettify(pp:selected()))
        end
  end

  local function current_display(s)
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

    vim.api.nvim_buf_set_lines(this.bufnr, 0, -1, false, st.prettify(s.config:system()))
    return this
  end

  local function picker_menu(s, pp, lines, upd_sel)
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
        pp:select(item.text)
        upd_sel(pp)
      end,
      on_submit = function()
        pp:confirm(s.config)
        state.ui_ctl:resume()
      end,
    })

    return menu
  end

  local lines = {}
  for k, _ in pairs(state.config:presets()) do
    table.insert(lines, Menu.item(k))
  end

  local pp = st.picker.setup(state.config:presets())
  local s, upd = selected_display()
  local c = current_display(state)
  local m = picker_menu(state, pp, lines, upd)

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

return M
