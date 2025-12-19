# Piega (Fold)

Piega is a Neovim plugin that provides intelligent, scope-aware code folding using Treesitter. It makes it easy to fold and unfold code blocks with intuitive keybindings.

## Features

- **Fold/Unfold Scope**: Intelligently fold or unfold the scope of the current line using Treesitter
- **Unfold All**: Unfold everything in the current buffer with a single command
- **Fold Same Level**: Fold all nodes at the same level (e.g., fold all methods in a class)
- **Treesitter-Based**: Uses Treesitter AST for accurate scope detection
- **Universal Compatibility**: Works with all major Neovim plugin managers

## Requirements

- Neovim >= 0.7.0
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- Treesitter parsers for your target languages

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'amartincodes/piega',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('piega').setup({
      -- your configuration here (optional)
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'amartincodes/piega',
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('piega').setup()
  end,
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'amartincodes/piega'

" In your init.vim or after plug#end()
lua << EOF
require('piega').setup()
EOF
```

### Using [pathogen](https://github.com/tpope/vim-pathogen)

```bash
cd ~/.vim/bundle
git clone https://github.com/amartincodes/piega.git
```

Then in your Neovim config:
```lua
require('piega').setup()
```

## Quick Start

After installation, add this to your configuration:

```lua
require('piega').setup()
```

Default keybindings:
- `<leader>zf` - Fold/unfold the scope of the current line
- `<leader>zu` - Unfold everything in the buffer
- `<leader>zl` - Fold all nodes at the same level as the current line

## Configuration

Here's the default configuration with all available options:

```lua
require('piega').setup({
  keymaps = {
    fold_scope = "<leader>zf",  -- Fold/unfold current scope
    unfold_all = "<leader>zu",   -- Unfold everything
    fold_level = "<leader>zl",   -- Fold all at same level
  },
  enabled = true,                -- Enable/disable plugin globally
  set_foldmethod = true,         -- Automatically set foldmethod to manual
  custom_foldtext = true,        -- Use custom fold text (shows line count)
  exclude_filetypes = {          -- Filetypes to exclude
    "help",
    "alpha",
    "dashboard",
    "NvimTree",
    "neo-tree",
    "Trouble",
  },
  foldable_nodes = {             -- Node types to consider foldable
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
    -- See lua/piega/config.lua for the full list
  },
})
```

### Custom Keybindings

You can customize the keybindings:

```lua
require('piega').setup({
  keymaps = {
    fold_scope = "zf",
    unfold_all = "zu",
    fold_level = "zl",
  },
})
```

Or disable default keybindings entirely and set your own:

```lua
require('piega').setup({
  keymaps = {
    fold_scope = false,
    unfold_all = false,
    fold_level = false,
  },
})

-- Then set your own keybindings
vim.keymap.set('n', 'zf', require('piega').fold_scope)
vim.keymap.set('n', 'zu', require('piega').unfold_all)
vim.keymap.set('n', 'zl', require('piega').fold_level)
```

### Custom Fold Display

By default, Piega uses a custom fold text that shows:
- The content of the first line
- The number of folded lines

Example of a folded block:
```
  icons = vim.g.have_nerd_font and {} or {  15 lines
```

To disable custom fold text and use Neovim's default:

```lua
require('piega').setup({
  custom_foldtext = false,
})
```

## Usage

### Fold/Unfold Current Scope

Position your cursor anywhere within a function, class, or other code block and press `<leader>zf`. Piega will use Treesitter to find the scope boundaries and fold it. Press again to unfold.

Example: With cursor inside a function:
```lua
function example()
  local x = 1
  if x > 0 then
    print("positive")
  end
end
```

After pressing `<leader>zf`, the entire function will be folded.

### Unfold All

Press `<leader>zu` to unfold all folds in the current buffer. This is useful when you want to see all the code at once.

### Fold Same Level

Press `<leader>zl` to fold all nodes at the same level as the current line. This is particularly useful for:

- Folding all methods in a class when cursor is on a method
- Folding all functions in a module
- Folding all if statements at the same nesting level

Example: With cursor on any method in this class:
```python
class Example:
    def method1(self):
        pass

    def method2(self):
        pass

    def method3(self):
        pass
```

After pressing `<leader>zl`, all three methods will be folded.

## Commands

Piega also provides Vim commands:

- `:PiegaFoldScope` - Fold/unfold current scope
- `:PiegaUnfoldAll` - Unfold all in buffer
- `:PiegaFoldLevel` - Fold all at same level

## API

You can also use the Lua API directly:

```lua
require('piega').fold_scope()   -- Fold/unfold current scope
require('piega').unfold_all()   -- Unfold all in buffer
require('piega').fold_level()   -- Fold all at same level
```

## Supported Languages

Piega works with any language that has a Treesitter parser. Out of the box, it includes foldable node configurations for:

- Lua
- Python
- JavaScript/TypeScript
- Rust
- Go
- C/C++
- Java

You can easily add support for more languages by extending the `foldable_nodes` configuration.

## Troubleshooting

### "nvim-treesitter is not installed" error

Install nvim-treesitter:
```lua
-- Using lazy.nvim
{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' }
```

### "No Treesitter parser for filetype" warning

Install the parser for your language:
```vim
:TSInstall <language>
```

For example: `:TSInstall python`, `:TSInstall lua`, etc.

### "No foldable scope found at cursor" warning

Your cursor might be in a location without a recognizable scope. Try moving the cursor inside a function, class, or other code block. You can also extend the `foldable_nodes` configuration for your language.

## Development & Testing

Piega includes a comprehensive test suite using [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

### Running Tests

Make sure you have plenary.nvim installed, then run:

```bash
make test
```

Or run a specific test file:

```bash
make test-file FILE=tests/config_spec.lua
```

### Test Coverage

The test suite covers:
- Configuration management and merging
- Treesitter node detection and range handling
- Folding operations and buffer management
- All supported languages including JSON

See [tests/README.md](tests/README.md) for more details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

When contributing:
1. Write tests for new features
2. Ensure all tests pass with `make test`
3. Follow the existing code style

## License

MIT License - see LICENSE file for details
