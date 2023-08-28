local ui = require("catalyst.ui")
local cf = require("catalyst.config")

local iron = require("iron.core")

local M = {}

local function set_keymaps(mod, keymaps)
  if keymaps == nil then return end

  if keymaps.pick then
    vim.keymap.set('n', keymaps.pick, mod.pick, { remap = true })
  end
  if keymaps.run then
    vim.keymap.set('n', keymaps.run, mod.run, { remap = false })
  end
  if keymaps.build then
    vim.keymap.set('n', keymaps.build, mod.build, { remap = false })
  end
  if keymaps.test then
    vim.keymap.set('n', keymaps.test, mod.test, { remap = false })
  end
end

local function setup(opts)
  if opts == nil then opts = {} end
  local cfg = cf.new(opts)

  local function pick()
    ui.pick(cfg)
  end

  local function run()
    iron.send('fish', cf.current(cfg).run)
  end

  local function build()
    iron.send('fish', cf.current(cfg).build)
  end

  local function test()
    iron.send('fish', cf.current(cfg).test)
  end

  M.pick = pick
  M.run = run
  M.build = build
  M.test = test

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

  vim.api.nvim_create_autocmd('DirChanged', {
    callback = function()
      cf.sync(cfg)
    end,
  })
  cf.sync(cfg)

  set_keymaps(M, opts.keymaps)
end

M.setup = setup
return M
