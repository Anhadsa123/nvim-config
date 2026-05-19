vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
  end,
})

vim.o.autoread = false

local ai_modify_group = vim.api.nvim_create_augroup("AiModifyWorkflow", { clear = true })
local global_modify_group = vim.api.nvim_create_augroup("GlobalModifyMode", { clear = true })

local function normal_file_buffer(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end

  if not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end

  if vim.bo[buf].buftype ~= "" then
    return false
  end

  if vim.api.nvim_buf_get_name(buf) == "" then
    return false
  end

  return true
end

local function safe_cmd(cmd)
  pcall(function()
    vim.cmd(cmd)
  end)
end

local function refresh_typst_tools()
  vim.schedule(function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"

    safe_cmd("TypstPreviewStop")
    safe_cmd("TypstPreview")
  end)
end

local function any_local_ai_locked_buffer()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if normal_file_buffer(buf) and vim.b[buf].ai_modify_locked == true then
      return true
    end
  end
  return false
end

local function modify_disable()
  local buf = vim.api.nvim_get_current_buf()

  if vim.g.global_modify_disabled == true then
    vim.notify("MD blocked: global modify mode is active; use :MGE first", vim.log.levels.WARN)
    return
  end

  if not normal_file_buffer(buf) then
    vim.notify("MD: not a normal file buffer", vim.log.levels.WARN)
    return
  end

  if vim.b[buf].global_modify_locked == true then
    vim.notify("MD blocked: buffer is globally locked; use :MGE first", vim.log.levels.WARN)
    return
  end

  if vim.b[buf].ai_modify_locked == true then
    vim.notify("MD blocked: buffer already locked", vim.log.levels.WARN)
    return
  end

  local ok, err = pcall(function()
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("write")
    end)
  end)

  if not ok then
    vim.notify("MD write failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.b[buf].ai_modify_locked = true
  vim.bo[buf].modifiable = false

  vim.notify("MD: file written and buffer locked", vim.log.levels.INFO)
end

local function modify_enable()
  local buf = vim.api.nvim_get_current_buf()

  if vim.g.global_modify_disabled == true then
    vim.notify("ME blocked: global modify mode is active; use :MGE first", vim.log.levels.WARN)
    return
  end

  if not normal_file_buffer(buf) then
    vim.notify("ME: not a normal file buffer", vim.log.levels.WARN)
    return
  end

  if vim.b[buf].global_modify_locked == true then
    vim.notify("ME blocked: buffer is globally locked; use :MGE first", vim.log.levels.WARN)
    return
  end

  if vim.b[buf].ai_modify_locked ~= true then
    vim.notify("ME blocked: run :MD first", vim.log.levels.WARN)
    return
  end

  local was_typst = vim.bo[buf].filetype == "typst"

  local ok, err = pcall(function()
    vim.api.nvim_buf_call(buf, function()
      vim.bo[buf].modifiable = true
      vim.cmd("silent! edit!")
      vim.bo[buf].modifiable = true
    end)
  end)

  if not ok then
    vim.bo[buf].modifiable = false
    vim.notify("ME reload failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.b[buf].ai_modify_locked = false
  vim.bo[buf].modifiable = true

  local write_ok, write_err = pcall(function()
    vim.api.nvim_buf_call(buf, function()
      vim.cmd("silent! write")
    end)
  end)

  if not write_ok then
    vim.b[buf].ai_modify_locked = true
    vim.bo[buf].modifiable = false
    vim.notify("ME write failed: " .. tostring(write_err), vim.log.levels.ERROR)
    return
  end

  if was_typst then
    refresh_typst_tools()
  end

  vim.notify("ME: file reloaded from disk and buffer unlocked", vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd("FileChangedShell", {
  group = ai_modify_group,
  callback = function(args)
    local buf = args.buf

    if vim.b[buf].ai_modify_locked == true or vim.b[buf].global_modify_locked == true then
      vim.v.fcs_choice = "ignore"
      vim.notify("External change ignored until :ME or :MGE", vim.log.levels.INFO)
    end
  end,
})

vim.api.nvim_create_user_command("ModifyDisable", modify_disable, {})
vim.api.nvim_create_user_command("ModifyEnable", modify_enable, {})
vim.api.nvim_create_user_command("MD", modify_disable, {})
vim.api.nvim_create_user_command("ME", modify_enable, {})

local function global_modify_disable()
  if vim.g.global_modify_disabled == true then
    vim.notify(
      "MGD blocked: global modify mode is already active; use :MGE first",
      vim.log.levels.WARN
    )
    return
  end

  if any_local_ai_locked_buffer() then
    vim.notify(
      "MGD blocked: a buffer is locally locked by :MD; run :ME first",
      vim.log.levels.WARN
    )
    return
  end

  local locked = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if normal_file_buffer(buf) then
      local ok, err = pcall(function()
        vim.api.nvim_buf_call(buf, function()
          if vim.bo[buf].modified then
            vim.cmd("silent! write")
          end
        end)
      end)

      if not ok then
        vim.notify("MGD write failed: " .. tostring(err), vim.log.levels.ERROR)
        return
      end

      vim.bo[buf].modifiable = false
      vim.b[buf].global_modify_locked = true
      locked = locked + 1
    end
  end

  vim.g.global_modify_disabled = true
  vim.notify(("MGD: globally locked %d buffers"):format(locked), vim.log.levels.INFO)
end

local function global_modify_enable()
  local unlocked = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if normal_file_buffer(buf) and vim.b[buf].global_modify_locked == true then
      vim.bo[buf].modifiable = true
      vim.b[buf].global_modify_locked = false
      unlocked = unlocked + 1
    end
  end

  vim.g.global_modify_disabled = false
  vim.notify(("MGE: globally unlocked %d buffers"):format(unlocked), vim.log.levels.INFO)
end

local function global_modify_toggle()
  if vim.g.global_modify_disabled == true then
    global_modify_enable()
  else
    global_modify_disable()
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = global_modify_group,
  callback = function(args)
    local buf = args.buf

    if vim.g.global_modify_disabled ~= true then
      return
    end

    if not normal_file_buffer(buf) then
      return
    end

    vim.bo[buf].modifiable = false
    vim.b[buf].global_modify_locked = true
  end,
})

vim.api.nvim_create_user_command("ModifyGlobalDisable", global_modify_disable, {})
vim.api.nvim_create_user_command("ModifyGlobalEnable", global_modify_enable, {})
vim.api.nvim_create_user_command("MGD", global_modify_disable, {})
vim.api.nvim_create_user_command("MGE", global_modify_enable, {})
vim.api.nvim_create_user_command("MGT", global_modify_toggle, {})

local function write_all_buffers()
  local written = 0
  local skipped = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if normal_file_buffer(buf) and vim.bo[buf].modified then
      if vim.bo[buf].readonly then
        skipped = skipped + 1
      else
        local ok = pcall(function()
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("silent! write")
          end)
        end)
        if ok then
          written = written + 1
        else
          skipped = skipped + 1
        end
      end
    end
  end

  vim.notify(("WA: wrote %d buffers; skipped %d"):format(written, skipped), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("WA", write_all_buffers, {})
vim.api.nvim_create_user_command("WriteAllBuffers", write_all_buffers, {})

local function load_all_buffers()
  local reloaded = 0
  local skipped_modified = 0
  local skipped_local_locked = 0
  local errors = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if normal_file_buffer(buf) then
      if vim.b[buf].ai_modify_locked == true then
        skipped_local_locked = skipped_local_locked + 1
      elseif vim.bo[buf].modified then
        skipped_modified = skipped_modified + 1
      else
        local was_global = vim.b[buf].global_modify_locked == true

        local ok, err = pcall(function()
          vim.api.nvim_buf_call(buf, function()
            if was_global then
              vim.bo[buf].modifiable = true
            end
            vim.cmd("silent! edit!")
            if was_global then
              vim.bo[buf].modifiable = false
              vim.b[buf].global_modify_locked = true
            else
              vim.bo[buf].modifiable = true
            end
          end)
        end)

        if ok then
          reloaded = reloaded + 1
        else
          errors = errors + 1
          vim.notify("LA failed for buffer " .. buf .. ": " .. tostring(err), vim.log.levels.ERROR)
          if was_global and vim.api.nvim_buf_is_valid(buf) then
            pcall(function()
              vim.api.nvim_buf_call(buf, function()
                vim.bo[buf].modifiable = false
                vim.b[buf].global_modify_locked = true
              end)
            end)
          end
        end
      end
    end
  end

  vim.notify(
    ("LA: reloaded %d; skipped %d modified; %d local-locked; %d errors"):format(
      reloaded,
      skipped_modified,
      skipped_local_locked,
      errors
    ),
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_user_command("LA", load_all_buffers, {})
vim.api.nvim_create_user_command("LoadAllBuffers", load_all_buffers, {})

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
    print(
      string.format(
        "%s | id=%d | root=%s",
        client.name,
        client.id,
        client.root_dir or "nil"
      )
    )
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
