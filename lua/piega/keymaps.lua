local M = {}

-- Store keymap IDs for cleanup
M._keymaps = {}

-- Setup keymaps based on configuration
function M.setup_keymaps(cfg)
  if not cfg or not cfg.keymaps then
    return
  end

  local keymaps = cfg.keymaps

  -- Fold/unfold current scope
  if keymaps.fold_scope then
    vim.keymap.set("n", keymaps.fold_scope, function()
      require("piega.fold").fold_current_scope()
    end, {
      desc = "Piega: Fold/unfold current scope",
      silent = true,
    })
    table.insert(M._keymaps, { mode = "n", lhs = keymaps.fold_scope })
  end

  -- Unfold all in buffer
  if keymaps.unfold_all then
    vim.keymap.set("n", keymaps.unfold_all, function()
      require("piega.fold").unfold_buffer()
    end, {
      desc = "Piega: Unfold all in buffer",
      silent = true,
    })
    table.insert(M._keymaps, { mode = "n", lhs = keymaps.unfold_all })
  end

  -- Fold all at same level
  if keymaps.fold_level then
    vim.keymap.set("n", keymaps.fold_level, function()
      require("piega.fold").fold_same_level()
    end, {
      desc = "Piega: Fold all at same level",
      silent = true,
    })
    table.insert(M._keymaps, { mode = "n", lhs = keymaps.fold_level })
  end

  -- Jump to next fold
  if keymaps.next_fold then
    vim.keymap.set("n", keymaps.next_fold, function()
      require("piega.navigation").next_fold()
    end, {
      desc = "Piega: Jump to next fold",
      silent = true,
    })
    table.insert(M._keymaps, { mode = "n", lhs = keymaps.next_fold })
  end

  -- Jump to previous fold
  if keymaps.prev_fold then
    vim.keymap.set("n", keymaps.prev_fold, function()
      require("piega.navigation").prev_fold()
    end, {
      desc = "Piega: Jump to previous fold",
      silent = true,
    })
    table.insert(M._keymaps, { mode = "n", lhs = keymaps.prev_fold })
  end
end

-- Clear all plugin keymaps
function M.clear_keymaps()
  for _, keymap in ipairs(M._keymaps) do
    pcall(vim.keymap.del, keymap.mode, keymap.lhs)
  end
  M._keymaps = {}
end

return M
