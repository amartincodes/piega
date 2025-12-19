-- Minimal init file for running tests
-- This sets up the necessary paths and dependencies

-- Add the current plugin to the runtimepath
vim.cmd([[set runtimepath+=.]])

-- Find and add plenary.nvim to the runtimepath
local function add_to_rtp(plugin_name)
  local possible_paths = {
    vim.fn.stdpath("data") .. "/lazy/" .. plugin_name,
    vim.fn.stdpath("data") .. "/site/pack/packer/start/" .. plugin_name,
    vim.fn.stdpath("data") .. "/site/pack/*/start/" .. plugin_name,
    vim.fn.expand("~/.local/share/nvim/lazy/" .. plugin_name),
    vim.fn.expand("~/.local/share/nvim/site/pack/vendor/start/" .. plugin_name),
  }

  for _, path in ipairs(possible_paths) do
    if vim.fn.isdirectory(vim.fn.glob(path)) == 1 then
      vim.opt.runtimepath:append(path)
      return true
    end
  end

  return false
end

-- Add required plugins
if not add_to_rtp("plenary.nvim") then
  print("WARNING: plenary.nvim not found. Tests may fail.")
end

add_to_rtp("nvim-treesitter")

-- Disable swap files and backups for tests
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
