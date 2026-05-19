-- ~/.config/nvim/lua/plugins/conceal.lua

return {
  {
    "pxwg/math-conceal.nvim",
    ft = { "typst" },
    config = function()
      require("math-conceal").setup({})
    end,
  },
}
