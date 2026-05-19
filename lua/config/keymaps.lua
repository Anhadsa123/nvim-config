-- ~/.config/nvim/lua/config/keymaps.lua

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Write file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move right" })

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal move left" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal move down" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal move up" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal move right" })

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

vim.keymap.set("c", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<C-z>"
end, { expr = true, desc = "Accept command-line completion" })

vim.keymap.set("c", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, desc = "Previous command-line completion" })


-- VimTeX ---------------------------------------------------------------------

vim.keymap.set("n", "<leader>lc", "<cmd>VimtexCompile<cr>", { desc = "LaTeX compile" })
vim.keymap.set("n", "<leader>lv", "<cmd>VimtexView<cr>", { desc = "LaTeX view PDF" })
vim.keymap.set("n", "<leader>ls", "<cmd>VimtexStop<cr>", { desc = "LaTeX stop compiler" })
vim.keymap.set("n", "<leader>le", "<cmd>VimtexErrors<cr>", { desc = "LaTeX errors" })
vim.keymap.set("n", "<leader>lk", "<cmd>VimtexClean<cr>", { desc = "LaTeX clean aux files" })
vim.keymap.set("n", "<leader>li", "<cmd>VimtexInfo<cr>", { desc = "LaTeX VimTeX info" })
vim.keymap.set("n", "<leader>lt", "<cmd>VimtexTocToggle<cr>", { desc = "LaTeX TOC toggle" })


-- Global modify lock ---------------------------------------------------------

vim.keymap.set("n", "<leader>mD", "<cmd>MGD<cr>", { desc = "Global modify disable" })
vim.keymap.set("n", "<leader>mE", "<cmd>MGE<cr>", { desc = "Global modify enable" })
vim.keymap.set("n", "<leader>mT", "<cmd>MGT<cr>", { desc = "Toggle global modify" })

-- AI buffer sync -------------------------------------------------------------

vim.keymap.set("n", "<leader>md", "<cmd>MD<cr>", {
  desc = "AI modify disable: write and lock buffer",
})

vim.keymap.set("n", "<leader>me", "<cmd>ME<cr>", {
  desc = "AI modify enable: reload from disk and unlock buffer",
})

vim.keymap.set("n", "<leader>mL", "<cmd>LA<cr>", {
  desc = "Load all unmodified buffers from disk",
})
