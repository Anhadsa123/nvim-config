vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Write file" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
vim.keymap.set("n", "<leader>ra", "<cmd>bufdo checktime<CR>", { desc = "Reload changed buffers" })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal window left" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal window down" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal window up" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal window right" })

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

vim.keymap.set("c", "<Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-y>" or "<C-z>"
end, { expr = true, desc = "Accept cmdline completion" })

vim.keymap.set("c", "<S-Tab>", function()
  return vim.fn.pumvisible() == 1 and "<C-p>" or "<S-Tab>"
end, { expr = true, desc = "Previous cmdline completion" })

vim.keymap.set("n", "<leader>md", "<cmd>MD<cr>", { desc = "Lock buffer for external edit" })
vim.keymap.set("n", "<leader>me", "<cmd>ME<cr>", { desc = "Reload buffer after external edit" })
vim.keymap.set("n", "<leader>mL", "<cmd>LA<cr>", { desc = "Reload all unmodified buffers" })
