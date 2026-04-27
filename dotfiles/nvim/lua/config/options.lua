-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Sync background with global theme
local theme_file = vim.fn.expand("~/.cache/theme_mode")
if vim.fn.filereadable(theme_file) == 1 then
  local mode = vim.fn.readfile(theme_file)[1]
  if mode == "dark" or mode == "light" then
    vim.opt.background = mode
  end
end
