local Menu = require("nui.menu")
local Popup = require("nui.popup")
local Layout = require("nui.layout")
local event = require("nui.utils.autocmd").event

local cf = require("catalyst.config")

local M = {}

local function persist_dialogue(preset)
  local user_input =
      vim.fn.confirm("Remember choice for current directory?", "&Yes\n&No", 2)

  if user_input == 1 then
    cf.persist(preset)
  end
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

local function picker_menu(cfg, lines, upd_sel)
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
      cf.select(cfg, item.text)
      upd_sel(cfg)
    end,
    on_submit = function()
      cf.confirm(cfg)
      persist_dialogue(cf.selected(cfg))
    end,
  })

  return menu
end

local function picker(s, c, m)
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

  p:mount()
  return p
end

function M.pick(cfg)
  local lines = {}
  for key, _ in pairs(cfg.presets) do
    table.insert(lines, Menu.item(key))
  end

  local s, upd = selected_display()
  local c = current_display(cfg)
  local m = picker_menu(cfg, lines, upd)

  picker(s, c, m)
end

return M
