# Catalyst

Quick project configuration for neovim.

# Install

With `packer.nvim`

```lua
use { 
  "head-gardener/catalyst",
  requires = {
    "hkupty/iron.nvim"
  }
}
```

# Configure

Call `setup` with empty table

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
