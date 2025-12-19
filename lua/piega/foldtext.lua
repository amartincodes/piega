local M = {}
local config = require("piega.config")

-- Get a nice fold text display
function M.get_foldtext()
  local line = vim.fn.getline(vim.v.foldstart)
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  local win_width = vim.api.nvim_win_get_width(0)

  -- Get configuration
  local ft_config = config.get().foldtext_config or {}

  -- Extract indentation
  local indent = line:match("^%s*") or ""
  local content = line:gsub("^%s*", ""):gsub("%s+$", "") -- Trim whitespace

  -- Icons for different contexts
  local fold_icon = ft_config.fold_icon or "󰅂"
  local line_icon = ft_config.line_icon or "󰦨"
  local padding_char = ft_config.padding_char or "·"

  -- Fallback to simple characters if nerd fonts not available
  if not ft_config.use_nerd_font then
    fold_icon = "▸"
    line_icon = "→"
  end

  -- Calculate available space
  local line_info = string.format(" %s %d lines ", line_icon, line_count)
  local available_width = win_width - vim.fn.strdisplaywidth(indent) - vim.fn.strdisplaywidth(line_info) - 3

  -- Truncate content if needed
  if vim.fn.strdisplaywidth(content) > available_width then
    -- Truncate smartly - try to keep the beginning which usually has important info
    while vim.fn.strdisplaywidth(content) > available_width - 1 do
      content = content:sub(1, -2)
    end
    content = content .. "…"
  end

  -- Build the fold text with padding
  local fold_text = string.format("%s%s %s", indent, fold_icon, content)

  -- Calculate padding to right-align the line count
  local text_width = vim.fn.strdisplaywidth(fold_text)
  local padding_width = win_width - text_width - vim.fn.strdisplaywidth(line_info) - 1
  local padding = string.rep(padding_char, math.max(0, padding_width))

  return fold_text .. " " .. padding .. line_info
end

-- Get adaptive colors based on current colorscheme
local function get_adaptive_colors()
  -- Get current colorscheme's colors
  local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
  local string_hl = vim.api.nvim_get_hl(0, { name = "String" })
  local identifier_hl = vim.api.nvim_get_hl(0, { name = "Identifier" })
  local cursorline_hl = vim.api.nvim_get_hl(0, { name = "CursorLine" })
  local visual_hl = vim.api.nvim_get_hl(0, { name = "Visual" })

  -- Use more prominent colors - prefer String or Identifier color
  local fg = string_hl.fg or identifier_hl.fg or normal_hl.fg

  -- Use a more visible background - blend CursorLine with Visual
  local bg = visual_hl.bg or cursorline_hl.bg or normal_hl.bg

  -- Brighten the foreground color if we have it
  if fg then
    -- Convert to RGB, increase brightness
    local r = math.floor(fg / 65536) % 256
    local g = math.floor(fg / 256) % 256
    local b = fg % 256

    -- Increase brightness by 20%
    r = math.min(255, math.floor(r * 1.2))
    g = math.min(255, math.floor(g * 1.2))
    b = math.min(255, math.floor(b * 1.2))

    fg = r * 65536 + g * 256 + b
  end

  return {
    fg = fg and string.format("#%06x", fg) or nil,
    bg = bg and string.format("#%06x", bg) or nil,
    italic = true,
    bold = true, -- Make it bold for better visibility
  }
end

-- Setup custom fold text for the current buffer
function M.setup_buffer()
  vim.opt_local.foldtext = "v:lua.require'piega.foldtext'.get_foldtext()"
  vim.opt_local.fillchars:append("fold: ")

  -- Add subtle highlighting for fold text (adaptive to colorscheme)
  vim.api.nvim_set_hl(0, "Folded", get_adaptive_colors())
end

return M
