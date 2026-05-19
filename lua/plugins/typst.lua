-- ~/.config/nvim/lua/plugins/typst.lua

return {
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {
      dependencies_bin = {
        ["tinymist"] = "tinymist",
      },
    },
    keys = {
      {
        "<leader>tp",
        "<cmd>TypstPreview<cr>",
        desc = "Typst preview",
      },
      {
        "<leader>ts",
        "<cmd>TypstPreviewStop<cr>",
        desc = "Stop Typst preview",
      },
    },
  },
}
