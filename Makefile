.PHONY: test test-file

# Run all tests
test:
	nvim --headless -u tests/minimal_init.lua \
		-c "lua require('plenary.test_harness').test_directory('tests/', { minimal_init = 'tests/minimal_init.lua' })"

# Run a specific test file
# Usage: make test-file FILE=tests/config_spec.lua
test-file:
	nvim --headless -u tests/minimal_init.lua \
		-c "lua require('plenary.busted').run('$(FILE)')"

# Run tests with coverage (if you add coverage tool later)
test-coverage:
	@echo "Coverage not yet implemented"

# Clean test artifacts
clean:
	rm -rf .test-cache/
