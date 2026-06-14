local group = vim.api.nvim_create_augroup("AiModifyWorkflow", { clear = true })

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
  pcall(vim.cmd, cmd)
end

local function refresh_typst_tools()
  vim.schedule(function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = "nc"
    safe_cmd("TypstPreviewStop")
    safe_cmd("TypstPreview")
  end)
end

local function modify_disable()
  local buf = vim.api.nvim_get_current_buf()

  if not normal_file_buffer(buf) then
    vim.notify("MD: not a normal file buffer", vim.log.levels.WARN)
    return
  end

  if vim.b[buf].ai_modify_locked then
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

  if not normal_file_buffer(buf) then
    vim.notify("ME: not a normal file buffer", vim.log.levels.WARN)
    return
  end

  if not vim.b[buf].ai_modify_locked then
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

local function load_all_buffers()
  local reloaded = 0
  local skipped_modified = 0
  local skipped_locked = 0
  local errors = 0

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if normal_file_buffer(buf) then
      if vim.b[buf].ai_modify_locked then
        skipped_locked = skipped_locked + 1
      elseif vim.bo[buf].modified then
        skipped_modified = skipped_modified + 1
      else
        local ok, err = pcall(function()
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("silent! edit!")
          end)
        end)

        if ok then
          reloaded = reloaded + 1
        else
          errors = errors + 1
          vim.notify("LA failed for buffer " .. buf .. ": " .. tostring(err), vim.log.levels.ERROR)
        end
      end
    end
  end

  vim.notify(
    ("LA: reloaded %d; skipped %d modified; %d locked; %d errors"):format(
      reloaded,
      skipped_modified,
      skipped_locked,
      errors
    ),
    vim.log.levels.INFO
  )
end

vim.api.nvim_create_autocmd("FileChangedShell", {
  group = group,
  callback = function(args)
    local buf = args.buf
    if vim.b[buf].ai_modify_locked then
      vim.v.fcs_choice = "ignore"
      vim.notify("External change ignored until :ME", vim.log.levels.INFO)
    end
  end,
})

vim.api.nvim_create_user_command("MD", modify_disable, {})
vim.api.nvim_create_user_command("ME", modify_enable, {})
vim.api.nvim_create_user_command("WA", write_all_buffers, {})
vim.api.nvim_create_user_command("LA", load_all_buffers, {})
