-- ~/.config/nvim/lua/plugins/venv.lua
-- ~/.config/nvim/lua/plugins/venv.lua

return {
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    ft = "python",
    opts = {
      name = {
        "venv",
        ".venv",
        "env",
        ".env",
      },
      auto_refresh = true,
    },
    keys = {
      {
        "<leader>vs",
        "<cmd>VenvSelect<cr>",
        desc = "Select Python venv",
      },
      {
        "<leader>vc",
        "<cmd>VenvSelectCached<cr>",
        desc = "Use cached Python venv",
      },
    },
  },
}
