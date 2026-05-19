-- ~/.config/nvim/lua/plugins/lualine.lua

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
        disabled_filetypes = {
          statusline = { "oil" },
        },
      },
    },
  },
}
