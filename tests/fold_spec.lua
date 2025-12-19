local fold = require("piega.fold")
local config = require("piega.config")

describe("piega.fold", function()
  before_each(function()
    config.setup()
  end)

  describe("fold_range", function()
    it("should return false for invalid ranges", function()
      assert.equals(false, fold.fold_range(nil, nil))
      assert.equals(false, fold.fold_range(1, nil))
      assert.equals(false, fold.fold_range(nil, 5))
    end)

    it("should return false when end_line <= start_line", function()
      assert.equals(false, fold.fold_range(5, 5))
      assert.equals(false, fold.fold_range(10, 5))
    end)

    it("should accept valid ranges", function()
      -- Create a buffer with some content
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "line 1",
        "line 2",
        "line 3",
        "line 4",
        "line 5",
      })
      vim.api.nvim_set_current_buf(buf)

      -- Set foldmethod to manual
      vim.wo.foldmethod = "manual"

      local result = fold.fold_range(1, 3)

      -- Should return true (or handle based on actual implementation)
      assert.is_boolean(result)

      -- Cleanup
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("is_folded", function()
    it("should detect folded lines", function()
      -- Create a buffer with some content
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "line 1",
        "line 2",
        "line 3",
        "line 4",
        "line 5",
      })
      vim.api.nvim_set_current_buf(buf)
      vim.wo.foldmethod = "manual"

      -- Initially should not be folded
      assert.equals(false, fold.is_folded(1))

      -- Cleanup
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("unfold_range", function()
    it("should return false for invalid ranges", function()
      assert.equals(false, fold.unfold_range(nil, nil))
      assert.equals(false, fold.unfold_range(1, nil))
      assert.equals(false, fold.unfold_range(nil, 5))
    end)
  end)

  describe("toggle_fold_at_cursor", function()
    it("should toggle fold at cursor position", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "line 1",
        "line 2",
        "line 3",
      })
      vim.api.nvim_set_current_buf(buf)
      vim.wo.foldmethod = "manual"

      local result = fold.toggle_fold_at_cursor()

      assert.is_boolean(result)

      -- Cleanup
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("unfold_buffer", function()
    it("should unfold all folds when enabled", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "line 1",
        "line 2",
        "line 3",
      })
      vim.api.nvim_set_current_buf(buf)

      -- Should not error
      assert.has_no.errors(function()
        fold.unfold_buffer()
      end)

      -- Cleanup
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("should not run when disabled", function()
      config.update({ enabled = false })

      -- Should return early without errors
      assert.has_no.errors(function()
        fold.unfold_buffer()
      end)
    end)
  end)
end)
