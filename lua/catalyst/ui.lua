local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

local cf = require("catalyst.config")

local M = {}

local function persist_dialogue(data)
  local input = Menu({
    position = "50%",
    size = {
      width = 25,
      height = 1,
    },
    border = {
      style = "single",
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    },
  }, {
    lines = {
      Menu.item("Save setting? (y/n)"),
    },
    max_width = 20,
    keymap = {
      close = { "n", "N", "<C-c>", "<Esc>" },
      submit = { "y", "<CR>", "Y" },
    },
    on_submit = function()
      cf.persist(data)
    end,
  })

  input:on(event.BufLeave, function()
    input:unmount()
  end)

  return input
end

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

local function current_display(cfg)
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

  vim.api.nvim_buf_set_lines(this.bufnr, 0, -1, false, cf.prettify(cf.current(cfg)))
  return this
end

local function menu(config, lines, update)
  return Menu({
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
      cf.select(config, item.text)
      update(config)
    end,
    on_submit = function()
      cf.confirm(config)
      persist_dialogue(cf.selected(config)):mount()
    end,
  })
end

function M.picker(config)
  local lines = {}
  for key, _ in pairs(config.presets) do
    table.insert(lines, Menu.item(key))
  end

  local s, upd = selected_display()
  local c = current_display(config)
  local m = menu(config, lines, upd)
  local width = 80

  return Layout(
    {
      relative = "editor",
      position = "50%",
      size = {
        width = width,
        height = "30%",
      },
    },
    Layout.Box({
      Layout.Box(m, { size = "20%" }),
      Layout.Box(s, { size = "40%" }),
      Layout.Box(c, { size = "40%" }),
    }, { dir = "row" })
  )
end

return M
