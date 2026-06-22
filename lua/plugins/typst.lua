local function setup_typst_conceal()
  vim.opt_local.conceallevel = 2
  vim.opt_local.concealcursor = "nc"
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = setup_typst_conceal,
})

return {
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {},
    keys = {
      { "<leader>tp", "<cmd>TypstPreview<cr>", desc = "Typst preview" },
      { "<leader>ts", "<cmd>TypstPreviewStop<cr>", desc = "Stop Typst preview" },
    },
  },

  {
    "pxwg/math-conceal.nvim",
    ft = "typst",
    config = function()
      require("math-conceal").setup({})
    end,
  },
}
