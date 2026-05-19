-- ~/.config/nvim/lua/plugins/autopairs.lua

return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      fast_wrap = {},
      disable_filetype = {
        "TelescopePrompt",
        "vim",
      },
    },
  },
}
