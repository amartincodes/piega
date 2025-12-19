local M = {}

-- Get a nice fold text display
function M.get_foldtext()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1

  -- Remove leading whitespace for cleaner display
  local indent = line:match("^%s*") or ""
  local content = line:gsub("^%s*", "")

  -- Truncate very long lines
  local max_length = vim.api.nvim_win_get_width(0) - 20
  if #content > max_length then
    content = content:sub(1, max_length - 3) .. "..."
  end

  -- Build the fold text
  local fold_text = string.format("%s%s  %d lines ", indent, content, line_count)

  return fold_text
end

-- Setup custom fold text for the current buffer
function M.setup_buffer()
  vim.opt_local.foldtext = "v:lua.require'piega.foldtext'.get_foldtext()"
  vim.opt_local.fillchars = "fold: "
end

return M
