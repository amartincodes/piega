local M = {}
local config = require("piega.config")

-- Check if nvim-treesitter is available
local has_treesitter, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
local has_parsers, parsers = pcall(require, "nvim-treesitter.parsers")

-- Notify error helper
local function notify_error(msg)
  vim.notify("[piega] " .. msg, vim.log.levels.ERROR)
end

-- Notify warning helper
local function notify_warn(msg)
  vim.notify("[piega] " .. msg, vim.log.levels.WARN)
end

-- Check if Treesitter is available
function M.is_available()
  return has_treesitter and has_parsers
end

-- Check if current buffer has a parser
function M.has_parser()
  if not M.is_available() then
    return false
  end

  return parsers.has_parser()
end

-- Get Treesitter node at cursor position
function M.get_node_at_cursor()
  if not M.is_available() then
    notify_error("nvim-treesitter is not installed")
    return nil
  end

  if not M.has_parser() then
    local filetype = vim.bo.filetype
    notify_warn("No Treesitter parser for filetype: " .. filetype)
    return nil
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_range = { cursor[1] - 1, cursor[2] }

  local bufnr = vim.api.nvim_get_current_buf()
  local parser = parsers.get_parser(bufnr)

  if not parser then
    return nil
  end

  local root = ts_utils.get_root_for_position(cursor_range[1], cursor_range[2], parser)

  if not root then
    return nil
  end

  local node = root:named_descendant_for_range(
    cursor_range[1],
    cursor_range[2],
    cursor_range[1],
    cursor_range[2]
  )

  return node
end

-- Check if a node type is foldable based on configuration
function M.is_foldable_node(node)
  if not node then
    return false
  end

  local foldable_types = config.get_foldable_nodes()
  local node_type = node:type()

  for _, foldable_type in ipairs(foldable_types) do
    if node_type == foldable_type then
      return true
    end
  end

  return false
end

-- Walk up the AST to find the nearest scope-defining parent node
function M.get_scope_node(node)
  if not node then
    return nil
  end

  -- Start with current node
  local current = node

  -- Walk up until we find a foldable node
  while current do
    if M.is_foldable_node(current) then
      return current
    end
    current = current:parent()
  end

  -- If no foldable parent found, check for nodes that start on the current line
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1] - 1  -- Convert to 0-indexed

  -- Get root node and search for foldable nodes on this line
  local bufnr = vim.api.nvim_get_current_buf()
  local parser = parsers.get_parser(bufnr)
  if parser then
    local root = ts_utils.get_root_for_position(cursor_line, 0, parser)
    if root then
      -- Find all nodes that start on the current line
      local function find_foldable_on_line(n)
        if not n then return nil end

        local start_row, _, _, _ = n:range()
        if start_row == cursor_line and M.is_foldable_node(n) then
          return n
        end

        -- Check children
        for child in n:iter_children() do
          local found = find_foldable_on_line(child)
          if found then return found end
        end

        return nil
      end

      local found_node = find_foldable_on_line(root)
      if found_node then
        return found_node
      end
    end
  end

  return nil
end

-- Get the line range for a node (converts 0-indexed to 1-indexed)
function M.get_node_range(node)
  if not node then
    return nil, nil
  end

  local start_row, _, end_row, _ = node:range()

  -- Convert from 0-indexed to 1-indexed
  return start_row + 1, end_row + 1
end

-- Get all sibling nodes with the same type as the given node
function M.get_sibling_nodes(node)
  if not node then
    return {}
  end

  local parent = node:parent()
  if not parent then
    return {}
  end

  local siblings = {}
  local node_type = node:type()

  -- Iterate through all children of the parent
  for child in parent:iter_children() do
    -- Include nodes with the same type, but not the original node itself
    if child:type() == node_type and child ~= node and M.is_foldable_node(child) then
      table.insert(siblings, child)
    end
  end

  return siblings
end

-- Get fold level based on AST depth
function M.get_fold_level(node)
  if not node then
    return 0
  end

  local level = 0
  local current = node

  while current do
    if M.is_foldable_node(current) then
      level = level + 1
    end
    current = current:parent()
  end

  return level
end

return M
