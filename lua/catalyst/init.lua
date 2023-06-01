local ui = require("catalyst.ui")
local cf = require("catalyst.config")

local iron = require("iron.core")
local Menu = require("nui.menu")

local function setup(opts)
  local config = cf.new(opts)

  local function pick()
    local lines = {}
    for key, _ in pairs(config.presets) do
      table.insert(lines, Menu.item(key))
    end
    local display = ui.display_fact()
    local picker = ui.menu_fact(config, lines, display)
    local layout = ui.layout_fact(picker, display)
    layout:mount()
  end

  local function run()
    iron.send('fish', cf.get(config).run)
  end

  local function build()
    iron.send('fish', cf.get(config).build)
  end

  local function test()
    iron.send('fish', cf.get(config).test)
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

return {
  setup = setup
}
