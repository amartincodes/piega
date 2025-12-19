local ts = require("piega.treesitter")
local config = require("piega.config")

describe("piega.treesitter", function()
  before_each(function()
    config.setup()
  end)

  describe("is_available", function()
    it("should check if treesitter is available", function()
      local result = ts.is_available()
      -- This will depend on whether nvim-treesitter is installed
      assert.is_boolean(result)
    end)
  end)

  describe("is_foldable_node", function()
    it("should return false for nil node", function()
      assert.equals(false, ts.is_foldable_node(nil))
    end)

    it("should return true for foldable lua nodes", function()
      -- Mock a node with a type method
      vim.bo.filetype = "lua"

      local mock_node = {
        type = function() return "function_declaration" end
      }

      assert.equals(true, ts.is_foldable_node(mock_node))
    end)

    it("should return false for non-foldable nodes", function()
      vim.bo.filetype = "lua"

      local mock_node = {
        type = function() return "identifier" end
      }

      assert.equals(false, ts.is_foldable_node(mock_node))
    end)

    it("should work with json object nodes", function()
      vim.bo.filetype = "json"

      local mock_node = {
        type = function() return "object" end
      }

      assert.equals(true, ts.is_foldable_node(mock_node))
    end)
  end)

  describe("get_node_range", function()
    it("should return nil for nil node", function()
      local start_line, end_line = ts.get_node_range(nil)

      assert.is_nil(start_line)
      assert.is_nil(end_line)
    end)

    it("should convert 0-indexed to 1-indexed ranges", function()
      local mock_node = {
        range = function() return 0, 0, 5, 0 end
      }

      local start_line, end_line = ts.get_node_range(mock_node)

      assert.equals(1, start_line)
      assert.equals(6, end_line)
    end)

    it("should handle multi-line ranges", function()
      local mock_node = {
        range = function() return 10, 0, 20, 0 end
      }

      local start_line, end_line = ts.get_node_range(mock_node)

      assert.equals(11, start_line)
      assert.equals(21, end_line)
    end)
  end)

  describe("get_fold_level", function()
    it("should return 0 for nil node", function()
      assert.equals(0, ts.get_fold_level(nil))
    end)

    it("should count foldable parent nodes", function()
      vim.bo.filetype = "lua"

      -- Create nested mock nodes
      local grandparent = {
        type = function() return "function_declaration" end,
        parent = function() return nil end,
      }

      local parent = {
        type = function() return "if_statement" end,
        parent = function() return grandparent end,
      }

      local node = {
        type = function() return "identifier" end,
        parent = function() return parent end,
      }

      local level = ts.get_fold_level(node)

      -- Should count the two foldable ancestors
      assert.equals(2, level)
    end)
  end)
end)
