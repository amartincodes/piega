local M = {}

-- Default configuration
M.defaults = {
	keymaps = {
		fold_scope = "<leader>zf",
		unfold_all = "<leader>zu",
		fold_level = "<leader>zl",
	},
	enabled = true,
	set_foldmethod = true,
	exclude_filetypes = { "help", "alpha", "dashboard", "NvimTree", "neo-tree", "Trouble" },
	foldable_nodes = {
		lua = {
			"function_declaration",
			"function_definition",
			"if_statement",
			"for_statement",
			"while_statement",
			"table_constructor",
		},
		python = {
			"function_definition",
			"class_definition",
			"if_statement",
			"for_statement",
			"while_statement",
			"with_statement",
		},
		javascript = {
			"function_declaration",
			"function_expression",
			"arrow_function",
			"class_declaration",
			"method_definition",
			"if_statement",
			"for_statement",
			"while_statement",
		},
		typescript = {
			"function_declaration",
			"function_expression",
			"arrow_function",
			"class_declaration",
			"method_definition",
			"interface_declaration",
			"type_alias_declaration",
			"if_statement",
			"for_statement",
			"while_statement",
		},
		rust = {
			"function_item",
			"impl_item",
			"struct_item",
			"enum_item",
			"if_expression",
			"for_expression",
			"while_expression",
			"loop_expression",
		},
		go = {
			"function_declaration",
			"method_declaration",
			"type_declaration",
			"if_statement",
			"for_statement",
		},
		c = {
			"function_definition",
			"struct_specifier",
			"if_statement",
			"for_statement",
			"while_statement",
		},
		cpp = {
			"function_definition",
			"class_specifier",
			"struct_specifier",
			"namespace_definition",
			"if_statement",
			"for_statement",
			"while_statement",
		},
		java = {
			"method_declaration",
			"class_declaration",
			"interface_declaration",
			"if_statement",
			"for_statement",
			"while_statement",
		},
		json = {
			"object",
			"array",
		},
		jsonc = {
			"object",
			"array",
		},
	},
}

-- Current runtime configuration
M._config = {}

-- Deep merge two tables
local function merge_tables(default, override)
	local result = vim.deepcopy(default)

	if not override then
		return result
	end

	for key, value in pairs(override) do
		if type(value) == "table" and type(result[key]) == "table" then
			result[key] = merge_tables(result[key], value)
		else
			result[key] = value
		end
	end

	return result
end

-- Setup configuration with user options
function M.setup(opts)
	M._config = merge_tables(M.defaults, opts or {})
	return M._config
end

-- Get current configuration
function M.get()
	return M._config
end

-- Update configuration at runtime
function M.update(opts)
	M._config = merge_tables(M._config, opts)
	return M._config
end

-- Check if plugin is enabled for current filetype
function M.is_enabled()
	local config = M.get()

	if not config.enabled then
		return false
	end

	local filetype = vim.bo.filetype
	for _, excluded_ft in ipairs(config.exclude_filetypes) do
		if filetype == excluded_ft then
			return false
		end
	end

	return true
end

-- Get foldable node types for current filetype
function M.get_foldable_nodes()
	local config = M.get()
	local filetype = vim.bo.filetype

	return config.foldable_nodes[filetype] or {}
end

return M
