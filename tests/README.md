# Piega Tests

This directory contains tests for the Piega plugin using [plenary.nvim](https://github.com/nvim-lua/plenary.nvim).

## Prerequisites

You need to have plenary.nvim installed. If you use lazy.nvim or another plugin manager, it's likely already installed.

## Running Tests

### Run all tests

```bash
make test
```

### Run a specific test file

```bash
make test-file FILE=tests/config_spec.lua
```

### Run tests manually with nvim

```bash
nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
```

### Run tests from within Neovim

1. Open Neovim from the plugin root directory
2. Run: `:PlenaryBustedDirectory tests/`

## Test Structure

- `config_spec.lua` - Tests for the configuration module
- `treesitter_spec.lua` - Tests for treesitter integration
- `fold_spec.lua` - Tests for folding functionality
- `minimal_init.lua` - Minimal Neovim config for running tests

## Writing Tests

Tests use plenary's busted-style testing framework. Example:

```lua
describe("module_name", function()
  before_each(function()
    -- Setup before each test
  end)

  it("should do something", function()
    assert.equals(expected, actual)
  end)
end)
```

## Assertions

Available assertions:
- `assert.equals(expected, actual)`
- `assert.is_true(value)`
- `assert.is_false(value)`
- `assert.is_nil(value)`
- `assert.is_not_nil(value)`
- `assert.has_error(function)`
- `assert.has_no.errors(function)`

## CI Integration

Tests are automatically run on GitHub Actions for every push and pull request. See `.github/workflows/test.yml` for details.
