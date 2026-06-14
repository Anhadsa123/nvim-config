return {
  {
    "mason-org/mason.nvim",
    lazy = false,
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    lazy = false,
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = { "lua_ls", "pyright", "tinymist" },
    },
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      vim.lsp.config("lua_ls", {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        root_markers = {
          ".luarc.json",
          ".luarc.jsonc",
          ".stylua.toml",
          "stylua.toml",
          ".git",
        },
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                vim.fn.stdpath("config"),
                vim.fn.stdpath("data") .. "/lazy",
              },
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
      })

      vim.lsp.config("tinymist", {
        cmd = { "tinymist" },
        filetypes = { "typst" },
      })

      vim.lsp.enable({ "lua_ls", "pyright", "tinymist" })
    end,
  },
}
