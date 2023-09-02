local M = {}

function M.setup(config)
  local this = {}

  this.presets = config:presets()
  this.selected = nil

  this.preset = next(this.presets, nil)

  function this:selected()
    return this.presets[this.preset]
  end

  function this:select(x)
    this.preset = x
  end

  function this:confirm(cf)
    cf:set(this:selected())
  end

  return this
end

return M
