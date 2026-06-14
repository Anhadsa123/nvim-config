return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = { "jmbuhr/otter.nvim" },
    opts = {
      lspFeatures = {
        enabled = true,
        chunks = "curly",
        languages = { "python", "bash", "html" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = { enabled = true },
      },
      codeRunner = {
        enabled = true,
        default_method = "slime",
        ft_runners = { python = "slime" },
        never_run = { "yaml" },
      },
    },
    keys = {
      {
        "<leader>qp",
        function()
          require("quarto").quartoPreview()
        end,
        desc = "Quarto preview",
      },
      { "<leader>qx", "<cmd>QuartoClosePreview<cr>", desc = "Close Quarto preview" },
      {
        "<leader>qr",
        function()
          require("quarto.runner").run_cell()
        end,
        desc = "Run Quarto cell",
      },
      {
        "<leader>qA",
        function()
          require("quarto.runner").run_all()
        end,
        desc = "Run all Quarto cells",
      },
      {
        "<leader>qi",
        function()
          vim.cmd("vsplit | terminal ipython")
        end,
        desc = "Open ipython terminal",
      },
    },
  },

  {
    "jpalardy/vim-slime",
    ft = { "quarto", "python" },
    init = function()
      vim.b["quarto_is_python_chunk"] = false
      _G.Quarto_is_in_python_chunk = function()
        require("otter.tools.functions").is_otter_language_context("python")
      end

      vim.g.slime_dispatch_ipython_pause = 100
      vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true

      vim.cmd([[
function! SlimeOverride_EscapeText_quarto(text)
  call v:lua.Quarto_is_in_python_chunk()
  if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk
    return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
  else
    return [a:text]
  endif
endfunction
      ]])
    end,
    keys = {
      {
        "<leader>qs",
        function()
          vim.fn["slime#config"]({})
        end,
        desc = "Set slime terminal",
      },
    },
  },
}
