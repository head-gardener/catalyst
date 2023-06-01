local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

local cf = require("catalyst.config")

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

local M = {}

local function display_fact()
  return Popup({
    enter = false,
    border = {
      style = "single",
      padding = { 0, 2 },
      text = {
        top = "-Build-System-",
        top_align = "center",
      },
    },
  })
end

local function menu_fact(config, lines, d)
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
      vim.api.nvim_buf_set_lines(d.bufnr, 0, -1, false, cf.prettify(cf.preset(config)))
    end,
    on_submit = function()
      cf.confirm(config)
      persist_dialogue(cf.preset(config)):mount()
    end,
  })
end

function M.picker(config)
  local lines = {}
  for key, _ in pairs(config.presets) do
    table.insert(lines, Menu.item(key))
  end

  local d = display_fact()
  local m = menu_fact(config, lines, d)

  return Layout(
    {
      position = "50%",
      size = {
        width = 80,
        height = "60%",
      },
    },
    Layout.Box({
      Layout.Box(m, { size = "30%" }),
      Layout.Box(d, { size = "70%" }),
    }, { dir = "row" })
  )
end

return M
