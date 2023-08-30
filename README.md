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

Call `setup` with empty table for defaults

```lua
require('catalyst').setup({})
```

Or provide configuration

```lua
require('catalyst').setup({
  presets = {
    cabal = { run = "cabal run app", build = "cabal build", test = "cabal test --test-show-details=direct" },
    stack = { run = "stack run", build = "stack build", test = "stack test" },
    cargo = { run = "cargo run", build = "cargo build", test = "cargo test" },
    make = { run = "make build && build/bin", build = "make build", test = "make check" },
    cmake = { run = "cmake run", build = "cmake build", test = "cmake check" },
  },
  keymaps = {
    run = '<Leader>mm',
    test = '<Leader>mt',
    build = '<Leader>mb',
    pick = '<Leader>mp',
  }
})
```
