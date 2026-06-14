if not vim.g.neovide then
  return
end

vim.g.neovide_opacity = 0.75
vim.g.neovide_normal_opacity = 0.75

local FONT_FAMILY = "IBM Plex Mono"
local DEFAULT_FONT_SIZE = 15
local MIN_FONT_SIZE = 8
local MAX_FONT_SIZE = 40

local function clamp(size)
  return math.max(MIN_FONT_SIZE, math.min(MAX_FONT_SIZE, math.floor(size)))
end

local function set_font_size(size)
  size = clamp(size)
  vim.g.neovide_font_size = size
  vim.opt.guifont = string.format("%s:h%d", FONT_FAMILY, size)
  print(string.format("Font size: %d", size))
end

set_font_size(DEFAULT_FONT_SIZE)

vim.api.nvim_create_user_command("FontSize", function(opts)
  local size = tonumber(opts.args)
  if not size then
    vim.notify("FontSize requires a number", vim.log.levels.ERROR)
    return
  end
  set_font_size(size)
end, { nargs = 1 })

vim.api.nvim_create_user_command("FontUp", function()
  set_font_size(vim.g.neovide_font_size + 1)
end, {})

vim.api.nvim_create_user_command("FontDown", function()
  set_font_size(vim.g.neovide_font_size - 1)
end, {})

vim.api.nvim_create_user_command("FontReset", function()
  set_font_size(DEFAULT_FONT_SIZE)
end, {})

vim.api.nvim_create_user_command("FontLaptop", function()
  set_font_size(14)
end, {})

vim.api.nvim_create_user_command("FontMonitor", function()
  set_font_size(17)
end, {})
