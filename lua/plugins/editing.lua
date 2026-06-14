return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      fast_wrap = {},
      disable_filetype = { "TelescopePrompt", "vim" },
    },
  },

  {
    "diegok/live-autoread.nvim",
    event = "VeryLazy",
    config = function()
      require("live-autoread").setup()
    end,
  },
}
