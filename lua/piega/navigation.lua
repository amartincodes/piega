local M = {}

-- Notify info helper
local function notify_info(msg)
  vim.notify("[piega] " .. msg, vim.log.levels.INFO)
end

-- Jump to the next fold in the buffer
function M.next_fold()
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")

  -- If we're currently on a folded line, skip past it first
  local current_fold_start = vim.fn.foldclosed(current_line)
  local start_search_line = current_line + 1

  if current_fold_start ~= -1 then
    -- We're on a folded line, jump past the end of this fold
    local current_fold_end = vim.fn.foldclosedend(current_line)
    start_search_line = current_fold_end + 1
  end

  -- Search forward for the next closed fold
  for line = start_search_line, total_lines do
    local fold_start = vim.fn.foldclosed(line)
    if fold_start ~= -1 and fold_start >= line then
      -- Found a fold, jump to its start
      vim.cmd("normal! " .. fold_start .. "G")
      return
    end
  end

  -- Wrap around to the beginning
  for line = 1, current_line do
    local fold_start = vim.fn.foldclosed(line)
    if fold_start ~= -1 and fold_start >= line then
      vim.cmd("normal! " .. fold_start .. "G")
      notify_info("Wrapped to first fold")
      return
    end
  end

  notify_info("No folds found in buffer")
end

-- Jump to the previous fold in the buffer
function M.prev_fold()
  local current_line = vim.fn.line(".")
  local total_lines = vim.fn.line("$")

  -- If we're currently on a folded line, get its start
  local current_fold_start = vim.fn.foldclosed(current_line)
  local start_search_line = current_line - 1

  if current_fold_start ~= -1 then
    -- We're on a folded line, search before this fold's start
    start_search_line = current_fold_start - 1
  end

  -- Search backward for the previous closed fold
  for line = start_search_line, 1, -1 do
    local fold_start = vim.fn.foldclosed(line)
    if fold_start ~= -1 and fold_start <= line then
      -- Found a fold, jump to its start
      vim.cmd("normal! " .. fold_start .. "G")
      return
    end
  end

  -- Wrap around to the end
  for line = total_lines, current_line, -1 do
    local fold_start = vim.fn.foldclosed(line)
    if fold_start ~= -1 and fold_start <= line then
      -- Skip if this is the current fold we're on
      if current_fold_start == -1 or fold_start ~= current_fold_start then
        vim.cmd("normal! " .. fold_start .. "G")
        notify_info("Wrapped to last fold")
        return
      end
    end
  end

  notify_info("No folds found in buffer")
end

-- Jump to the next fold (including open ones) based on treesitter
function M.next_foldable_scope()
  local ts = require("piega.treesitter")
  local config = require("piega.config")

  if not config.is_enabled() then
    return
  end

  if not ts.is_available() or not ts.has_parser() then
    -- Fallback to next closed fold
    M.next_fold()
    return
  end

  local current_line = vim.fn.line(".")
  local bufnr = vim.api.nvim_get_current_buf()
  local total_lines = vim.fn.line("$")

  -- Get all foldable nodes in the buffer
  local parsers = require("nvim-treesitter.parsers")
  local ts_utils = require("nvim-treesitter.ts_utils")

  local parser = parsers.get_parser(bufnr)
  if not parser then
    M.next_fold()
    return
  end

  local foldable_lines = {}

  -- Find all foldable node start lines
  local function find_foldable_nodes(node)
    if not node then return end

    if ts.is_foldable_node(node) then
      local start_row, _, _, _ = node:range()
      table.insert(foldable_lines, start_row + 1) -- Convert to 1-indexed
    end

    for child in node:iter_children() do
      find_foldable_nodes(child)
    end
  end

  -- Parse and find foldable nodes
  for i = 0, total_lines - 1 do
    local root = ts_utils.get_root_for_position(i, 0, parser)
    if root then
      find_foldable_nodes(root)
      break -- Only need to do this once for the whole buffer
    end
  end

  -- Remove duplicates and sort
  local seen = {}
  local unique_lines = {}
  for _, line in ipairs(foldable_lines) do
    if not seen[line] then
      seen[line] = true
      table.insert(unique_lines, line)
    end
  end
  table.sort(unique_lines)

  -- Find next foldable line
  for _, line in ipairs(unique_lines) do
    if line > current_line then
      vim.cmd("normal! " .. line .. "G")
      return
    end
  end

  -- Wrap around to first
  if #unique_lines > 0 then
    vim.cmd("normal! " .. unique_lines[1] .. "G")
    notify_info("Wrapped to first foldable scope")
  else
    notify_info("No foldable scopes found")
  end
end

-- Jump to the previous fold (including open ones) based on treesitter
function M.prev_foldable_scope()
  local ts = require("piega.treesitter")
  local config = require("piega.config")

  if not config.is_enabled() then
    return
  end

  if not ts.is_available() or not ts.has_parser() then
    -- Fallback to prev closed fold
    M.prev_fold()
    return
  end

  local current_line = vim.fn.line(".")
  local bufnr = vim.api.nvim_get_current_buf()
  local total_lines = vim.fn.line("$")

  -- Get all foldable nodes in the buffer
  local parsers = require("nvim-treesitter.parsers")
  local ts_utils = require("nvim-treesitter.ts_utils")

  local parser = parsers.get_parser(bufnr)
  if not parser then
    M.prev_fold()
    return
  end

  local foldable_lines = {}

  -- Find all foldable node start lines
  local function find_foldable_nodes(node)
    if not node then return end

    if ts.is_foldable_node(node) then
      local start_row, _, _, _ = node:range()
      table.insert(foldable_lines, start_row + 1) -- Convert to 1-indexed
    end

    for child in node:iter_children() do
      find_foldable_nodes(child)
    end
  end

  -- Parse and find foldable nodes
  for i = 0, total_lines - 1 do
    local root = ts_utils.get_root_for_position(i, 0, parser)
    if root then
      find_foldable_nodes(root)
      break
    end
  end

  -- Remove duplicates and sort
  local seen = {}
  local unique_lines = {}
  for _, line in ipairs(foldable_lines) do
    if not seen[line] then
      seen[line] = true
      table.insert(unique_lines, line)
    end
  end
  table.sort(unique_lines)

  -- Find previous foldable line
  for i = #unique_lines, 1, -1 do
    if unique_lines[i] < current_line then
      vim.cmd("normal! " .. unique_lines[i] .. "G")
      return
    end
  end

  -- Wrap around to last
  if #unique_lines > 0 then
    vim.cmd("normal! " .. unique_lines[#unique_lines] .. "G")
    notify_info("Wrapped to last foldable scope")
  else
    notify_info("No foldable scopes found")
  end
end

return M
