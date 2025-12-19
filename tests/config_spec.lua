local config = require("piega.config")

describe("piega.config", function()
  before_each(function()
    -- Reset config before each test
    config._config = {}
  end)

  describe("setup", function()
    it("should initialize with default configuration", function()
      local result = config.setup()

      assert.is_not_nil(result)
      assert.equals(true, result.enabled)
      assert.equals(true, result.set_foldmethod)
      assert.equals("<leader>zf", result.keymaps.fold_scope)
      assert.equals("<leader>zu", result.keymaps.unfold_all)
      assert.equals("<leader>zl", result.keymaps.fold_level)
    end)

    it("should merge user options with defaults", function()
      local result = config.setup({
        enabled = false,
        keymaps = {
          fold_scope = "zf",
        },
      })

      assert.equals(false, result.enabled)
      assert.equals("zf", result.keymaps.fold_scope)
      -- Should keep other defaults
      assert.equals("<leader>zu", result.keymaps.unfold_all)
    end)

    it("should handle custom foldable nodes", function()
      local result = config.setup({
        foldable_nodes = {
          custom_lang = {
            "custom_node",
          },
        },
      })

      assert.is_not_nil(result.foldable_nodes.custom_lang)
      assert.equals("custom_node", result.foldable_nodes.custom_lang[1])
      -- Should still have defaults
      assert.is_not_nil(result.foldable_nodes.lua)
    end)
  end)

  describe("get", function()
    it("should return current configuration", function()
      config.setup({ enabled = false })
      local result = config.get()

      assert.equals(false, result.enabled)
    end)
  end)

  describe("update", function()
    it("should update configuration at runtime", function()
      config.setup({ enabled = true })
      config.update({ enabled = false })

      local result = config.get()
      assert.equals(false, result.enabled)
    end)
  end)

  describe("is_enabled", function()
    it("should return false when globally disabled", function()
      config.setup({ enabled = false })

      assert.equals(false, config.is_enabled())
    end)

    it("should return false for excluded filetypes", function()
      config.setup({
        enabled = true,
        exclude_filetypes = { "help", "alpha" },
      })

      vim.bo.filetype = "help"
      assert.equals(false, config.is_enabled())

      vim.bo.filetype = "lua"
      assert.equals(true, config.is_enabled())
    end)
  end)

  describe("get_foldable_nodes", function()
    it("should return foldable nodes for lua", function()
      config.setup()
      vim.bo.filetype = "lua"

      local nodes = config.get_foldable_nodes()

      assert.is_not_nil(nodes)
      assert.is_true(#nodes > 0)
      assert.is_true(vim.tbl_contains(nodes, "function_declaration"))
    end)

    it("should return empty table for unknown filetype", function()
      config.setup()
      vim.bo.filetype = "unknown_language"

      local nodes = config.get_foldable_nodes()

      assert.is_not_nil(nodes)
      assert.equals(0, #nodes)
    end)

    it("should return nodes for json filetype", function()
      config.setup()
      vim.bo.filetype = "json"

      local nodes = config.get_foldable_nodes()

      assert.is_true(vim.tbl_contains(nodes, "object"))
      assert.is_true(vim.tbl_contains(nodes, "array"))
    end)
  end)
end)
