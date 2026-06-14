vim.api.nvim_create_user_command("Rall", function()
  vim.cmd("bufdo edit!")
end, { desc = "Force reload all buffers from disk" })

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd("checkhealth vim.lsp")
end, {})

vim.api.nvim_create_user_command("LspClients", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  if #clients == 0 then
    vim.notify("No LSP clients attached to current buffer", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    print(string.format("%s | id=%d | root=%s", client.name, client.id, client.root_dir or "nil"))
  end
end, {})

vim.api.nvim_create_user_command("LspRestart", function()
  local clients = vim.lsp.get_clients()

  if #clients == 0 then
    vim.notify("No active LSP clients", vim.log.levels.WARN)
    return
  end

  for _, client in ipairs(clients) do
    client:stop()
  end

  vim.defer_fn(function()
    local buf = vim.api.nvim_get_current_buf()
    if not vim.api.nvim_buf_is_valid(buf) then
      return
    end

    vim.api.nvim_buf_call(buf, function()
      if vim.bo.modified then
        vim.cmd("silent! write")
        if vim.bo.modified then
          vim.notify(
            "LspRestart: buffer still modified after write; skipping :edit to avoid E37",
            vim.log.levels.WARN
          )
          return
        end
      end
      vim.cmd("edit")
    end)
  end, 500)

  vim.notify("LSP restarted", vim.log.levels.INFO)
end, {})
