local M = {}

-- Plugin metadata
M.version = "0.1.0"
M.name = "piega"

-- Check if plugin has been initialized
local initialized = false

-- Notify error helper
local function notify_error(msg)
  vim.notify("[piega] " .. msg, vim.log.levels.ERROR)
end

-- Setup the plugin with user configuration
function M.setup(opts)
  -- Prevent double initialization
  if initialized then
    return
  end

  -- Check for nvim-treesitter
  local has_treesitter = pcall(require, "nvim-treesitter")
  if not has_treesitter then
    notify_error("nvim-treesitter is required. Please install it first.")
    return
  end

  -- Load and setup configuration
  local config = require("piega.config")
  config.setup(opts or {})

  -- Setup keymaps
  local keymaps = require("piega.keymaps")
  keymaps.setup_keymaps(config.get())

  -- Set foldmethod and foldtext if configured
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
      if config.is_enabled() then
        -- Set foldmethod to manual if configured
        if config.get().set_foldmethod then
          vim.opt_local.foldmethod = "manual"
        end

        -- Setup custom foldtext if configured
        if config.get().custom_foldtext then
          local foldtext = require("piega.foldtext")
          foldtext.setup_buffer()
        end
      end
    end,
  })

  initialized = true
end

-- Public API: Fold/unfold current scope
function M.fold_scope()
  if not initialized then
    notify_error("Plugin not initialized. Call require('piega').setup() first")
    return
  end

  require("piega.fold").fold_current_scope()
end

-- Public API: Unfold all in buffer
function M.unfold_all()
  if not initialized then
    notify_error("Plugin not initialized. Call require('piega').setup() first")
    return
  end

  require("piega.fold").unfold_buffer()
end

-- Public API: Fold all at same level
function M.fold_level()
  if not initialized then
    notify_error("Plugin not initialized. Call require('piega').setup() first")
    return
  end

  require("piega.fold").fold_same_level()
end

-- Public API: Check if plugin is initialized
function M.is_initialized()
  return initialized
end

-- Public API: Get current configuration
function M.get_config()
  return require("piega.config").get()
end

-- Public API: Update configuration at runtime
function M.update_config(opts)
  if not initialized then
    notify_error("Plugin not initialized. Call require('piega').setup() first")
    return
  end

  local config = require("piega.config")
  config.update(opts)

  -- Reapply keymaps if they changed
  if opts.keymaps then
    local keymaps = require("piega.keymaps")
    keymaps.clear_keymaps()
    keymaps.setup_keymaps(config.get())
  end
end

return M
