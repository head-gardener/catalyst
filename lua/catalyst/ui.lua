local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local cf = require("catalyst.config")

local M = {}

function M.display_fact()
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

function M.menu_fact(config, lines, d)
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
      cf.set(config, item.text)
      vim.api.nvim_buf_set_lines(d.bufnr, 0, -1, false, cf.prettify(cf.get(config)))
    end,
  })
end

function M.layout_fact(m, d)
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
