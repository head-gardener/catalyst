local function setup(opts)
  local Menu = require("nui.menu")
  local Popup = require("nui.popup")
  local Layout = require("nui.layout")
  local iron = require("iron.core")

  local presets = {
    cabal = { run = "cabal run", build = "cabal build", test = "cabal test" },
    cargo = { run = "cargo run", build = "cargo build", test = "cargo test" },
    make = { run = "make build && build/bin", build = "make build", test = "make check" },
    cmake = { run = "cmake run", build = "cmake build", test = "cmake check" },
  }

  local function prettify(a)
    return { "run: " .. a.run, "build: " .. a.build, "test: " .. a.test }
  end

  local preset = "cabal"

  local function get()
    return presets[preset]
  end

  local function set(x)
    preset = x
  end


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

  local function menu_fact(lines, d)
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
        set(item.text)
        vim.api.nvim_buf_set_lines(d.bufnr, 0, -1, false, prettify(get()))
      end,
    })
  end

  local function layout_fact(m, d)
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

  local function pick()
    local lines = {}
    for key, _ in pairs(presets) do
      table.insert(lines, Menu.item(key))
    end
    local display = display_fact()
    local picker = menu_fact(lines, display)
    local layout = layout_fact(picker, display)
    layout:mount()
  end

  local function run()
    iron.send('fish', presets[preset].run)
  end

  local function build()
    iron.send('fish', presets[preset].build)
  end

  local function test()
    iron.send('fish', presets[preset].test)
  end

  vim.api.nvim_create_user_command('CatlPick',
    pick,
    { nargs = '?' })
  vim.api.nvim_create_user_command('CatlRun',
    run,
    { nargs = '?' })
  vim.api.nvim_create_user_command('CatlBuild',
    build,
    { nargs = '?' })
  vim.api.nvim_create_user_command('CatlTest',
    test,
    { nargs = '?' })
end


local catalyst = {
  setup = setup
}

return catalyst
