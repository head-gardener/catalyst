# Catalyst

![image](https://github.com/head-gardener/catalyst/assets/49650767/c3ce0530-da78-4253-9caf-de411ee30c40)

Quick project configuration for neovim.

# Install

With `packer.nvim`

```lua
use { 
  "head-gardener/catalyst",
  requires = {
    "hkupty/iron.nvim",
    "MunifTanjim/nui.nvim",
  }
}
```

On dependencies:
- `iron.nvim` provides a terminal. Will be optional in the future.
- `nui.nvim` provides UI components. Might be replaced with telescope at some point.

# Configure

| :zap: First, configure `iron.nvim` to be able to run your favorite shell. |
|----------------------------------------------------------------------------|

### My favorite shell?

```lua
local catalyst = require('catalyst')
catalyst.setup({ shell = 'fish' })

...
```

Or leave blank if you use bash.

### I don't care, give me the defaults

```lua
local catalyst = require('catalyst')
catalyst.setup({})

vim.keymap.set('n', '<Leader>mm', catalyst.run(),   { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>mb', catalyst.build(), { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>mt', catalyst.test(),  { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>mp', catalyst.pick(),  { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>me', catalyst.edit(),  { noremap = true, silent = true })
```

This will give you all the necessary keybinds and default presets, which you will be able to modify with `:CatlEdit` or the keymap on per project basis.

### I want to add my own presets

```lua
local catalyst = require('catalyst')
catalyst.setup({
  presets = {
    stack = { run = "stack run", build = "stack build", test = "stack test" },
    cargo = { run = "cargo run", build = "cargo build", test = "cargo test" },
    make = { run = "make build && build/bin", build = "make build", test = "make check" },
  },
})

...
```

Keep frequently used configurations always available within one click.

### I need more commands

```lua
require('catalyst').setup({
  presets = {
    make = { 
        run = "make build && build/bin",
        build = "make build",
        test = "make check",
        watch = "find src -name '*.c' | entr make build" },
  },
  functions = {
    { 'run',   '<Leader>mm' },
    { 'test',  '<Leader>mt' },
    { 'build', '<Leader>mb' },
    { 'pick',  },
    { 'edit',  },
    { 'watch', '<Leader>mw' },
  },
})
```

Use `functions` field to add keybinds automatically (or leave second field blank to avoid that) and add custom commands **(WIP)**.
