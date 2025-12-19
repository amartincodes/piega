local M = {}
local ts = require("piega.treesitter")
local config = require("piega.config")

-- Notify info helper
local function notify_info(msg)
  vim.notify("[piega] " .. msg, vim.log.levels.INFO)
end

-- Notify warning helper
local function notify_warn(msg)
  vim.notify("[piega] " .. msg, vim.log.levels.WARN)
end

-- Create a fold for the given line range
function M.fold_range(start_line, end_line)
  if not start_line or not end_line then
    return false
  end

  -- Ensure we have at least 2 lines to fold
  if end_line <= start_line then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()

  -- Save current fold method
  local current_foldmethod = vim.api.nvim_buf_get_option(bufnr, "foldmethod")

  -- Temporarily set to manual for creating folds
  vim.api.nvim_buf_set_option(bufnr, "foldmethod", "manual")

  -- Create the fold
  local success = pcall(function()
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd(start_line .. "," .. end_line .. "fold")
    end)
  end)

  -- Restore original fold method if set_foldmethod is false
  if not config.get().set_foldmethod then
    vim.api.nvim_buf_set_option(bufnr, "foldmethod", current_foldmethod)
  end

  return success
end

-- Remove fold for the given line range
function M.unfold_range(start_line, end_line)
  if not start_line or not end_line then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local success = pcall(function()
    vim.api.nvim_buf_call(bufnr, function()
      -- Move to the start line and unfold
      vim.cmd("normal! " .. start_line .. "G")
      vim.cmd("normal! zd")
    end)
  end)

  return success
end

-- Check if a line is currently folded
function M.is_folded(line)
  local fold_start = vim.fn.foldclosed(line)
  return fold_start ~= -1
end

-- Toggle fold at cursor position
function M.toggle_fold_at_cursor()
  local line = vim.fn.line(".")
  local success = pcall(function()
    vim.cmd("normal! za")
  end)
  return success
end

-- Fold/unfold the scope of the current line
function M.fold_current_scope()
  if not config.is_enabled() then
    return
  end

  if not ts.is_available() then
    notify_warn("Treesitter is not available")
    return
  end

  if not ts.has_parser() then
    notify_warn("No Treesitter parser for current filetype")
    return
  end

  -- Get node at cursor
  local node = ts.get_node_at_cursor()
  if not node then
    notify_warn("Could not find Treesitter node at cursor")
    return
  end

  -- Find the scope node
  local scope_node = ts.get_scope_node(node)
  if not scope_node then
    notify_warn("No foldable scope found at cursor")
    return
  end

  -- Get the line range
  local start_line, end_line = ts.get_node_range(scope_node)
  if not start_line or not end_line then
    notify_warn("Could not determine scope range")
    return
  end

  -- Check if already folded and toggle
  if M.is_folded(start_line) then
    M.unfold_range(start_line, end_line)
  else
    local success = M.fold_range(start_line, end_line)
    if success then
      notify_info("Folded scope from line " .. start_line .. " to " .. end_line)
    end
  end
end

-- Unfold everything in the current buffer
function M.unfold_buffer()
  if not config.is_enabled() then
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  local success = pcall(function()
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("normal! zR")
    end)
  end)

  if success then
    notify_info("Unfolded all folds in buffer")
  end
end

-- Fold all nodes at the same level as the current line
function M.fold_same_level()
  if not config.is_enabled() then
    return
  end

  if not ts.is_available() then
    notify_warn("Treesitter is not available")
    return
  end

  if not ts.has_parser() then
    notify_warn("No Treesitter parser for current filetype")
    return
  end

  -- Get node at cursor
  local node = ts.get_node_at_cursor()
  if not node then
    notify_warn("Could not find Treesitter node at cursor")
    return
  end

  -- Find the scope node
  local scope_node = ts.get_scope_node(node)
  if not scope_node then
    notify_warn("No foldable scope found at cursor")
    return
  end

  -- Get all sibling nodes
  local siblings = ts.get_sibling_nodes(scope_node)

  if #siblings == 0 then
    notify_warn("No sibling nodes found at the same level")
    return
  end

  -- Also fold the current scope node
  local current_start, current_end = ts.get_node_range(scope_node)
  if current_start and current_end then
    M.fold_range(current_start, current_end)
  end

  -- Fold each sibling
  local fold_count = 1 -- Count current node
  for _, sibling in ipairs(siblings) do
    local start_line, end_line = ts.get_node_range(sibling)
    if start_line and end_line then
      local success = M.fold_range(start_line, end_line)
      if success then
        fold_count = fold_count + 1
      end
    end
  end

  notify_info("Folded " .. fold_count .. " node(s) at the same level")
end

return M
