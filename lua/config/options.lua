vim.env.PATH = vim.fn.expand("~/.local/bin") .. ":" .. vim.env.PATH

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.wrap = true
vim.o.termguicolors = true
vim.o.signcolumn = "yes"

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.undofile = true
vim.o.swapfile = false
vim.o.backup = false

vim.o.updatetime = 250
vim.o.timeoutlen = 400
vim.o.autoread = true

vim.o.wildmenu = true
vim.o.wildmode = "longest:full,full"
vim.o.wildoptions = "pum"

vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
})

local transparent_groups = {
  "Normal",
  "NormalNC",
  "NormalFloat",
  "FloatBorder",
  "Pmenu",
  "PmenuSel",
  "SignColumn",
  "LineNr",
  "CursorLineNr",
  "StatusLine",
  "StatusLineNC",
  "TabLine",
  "TabLineFill",
  "TabLineSel",
  "WinSeparator",
}

local function set_transparent_bg()
  for _, group in ipairs(transparent_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_transparent_bg,
})

set_transparent_bg()
