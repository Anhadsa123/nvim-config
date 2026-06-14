return {
  {
    "goerz/jupytext.nvim",
    version = "0.2.0",
    lazy = false,
    opts = {
      format = "py:percent",
      filetype = "python",
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-telescope/telescope.nvim",
    },
    ft = { "python", "quarto" },
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      auto_refresh = true,
    },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Select Python venv" },
      { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Use cached Python venv" },
    },
  },
}
