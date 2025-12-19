-- Luacheck configuration for Piega
-- https://luacheck.readthedocs.io/en/stable/config.html

-- Allow vim global
globals = {
  "vim",
}

-- Ignore some pedantic warnings
ignore = {
  "212", -- Unused argument
  "631", -- Line is too long
}

-- Read globals from other files
read_globals = {
  "describe",
  "it",
  "before_each",
  "after_each",
  "assert",
}

-- Exclude directories
exclude_files = {
  ".git/",
  "doc/",
}
