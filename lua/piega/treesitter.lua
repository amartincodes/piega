local M = {}
local config = require("piega.config")

-- Check if runtime Treesitter API is available
local has_treesitter = vim.treesitter and type(vim.treesitter.get_parser) == "function"
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
  return has_treesitter
end

-- Check if current buffer has a parser
function M.has_parser()
  if not M.is_available() then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local ok = pcall(vim.treesitter.get_parser, bufnr)
  if ok then
    return true
  end

  if has_parsers and parsers.has_parser then
    local filetype = vim.bo[bufnr].filetype
    return parsers.has_parser(filetype)
  end

  return false
end

-- Get Treesitter node at cursor position
function M.get_node_at_cursor()
  if not M.is_available() then
    notify_error("Treesitter runtime is not available")
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
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

  if not ok or not parser then
    return nil
  end

  local trees = parser:parse()
  local root = trees and trees[1] and trees[1]:root() or nil

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

  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1] - 1  -- Convert to 0-indexed
  local cursor_col = cursor[2]

  -- FIRST: Search for all foldable nodes on the current line
  local bufnr = vim.api.nvim_get_current_buf()
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

  if ok and parser then
    local trees = parser:parse()
    local root = trees and trees[1] and trees[1]:root() or nil
    if root then
      local nodes_on_line = {}

      -- Recursively find all foldable nodes that start on the current line
      local function find_nodes_on_line(n)
        if not n then return end

        local start_row, start_col, end_row, _ = n:range()

        -- If node starts on cursor line and is foldable, add it
        if start_row == cursor_line and M.is_foldable_node(n) then
          -- Also verify it contains content beyond the current line (multi-line)
          if end_row > start_row then
            table.insert(nodes_on_line, {
              node = n,
              start_col = start_col,
            })
          end
        end

        -- Continue searching children
        for child in n:iter_children() do
          find_nodes_on_line(child)
        end
      end

      find_nodes_on_line(root)

      -- If we found foldable nodes on this line, pick the best one
      if #nodes_on_line > 0 then
        -- Sort by column position
        table.sort(nodes_on_line, function(a, b)
          return a.start_col < b.start_col
        end)

        -- Find the first node that starts at or after cursor
        for _, info in ipairs(nodes_on_line) do
          if info.start_col >= cursor_col then
            return info.node
          end
        end

        -- If no node starts at or after cursor, take the last one (rightmost)
        return nodes_on_line[#nodes_on_line].node
      end
    end
  end

  -- SECOND: No foldable nodes on current line, walk up from cursor to find containing scope
  local current = node
  while current do
    if M.is_foldable_node(current) then
      return current
    end
    current = current:parent()
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
