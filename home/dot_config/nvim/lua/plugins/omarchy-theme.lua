-- Omarchy publishes the active theme's LazyVim spec at this path and rewrites
-- it on omarchy-theme-set; loading it keeps nvim in sync with the system theme.
-- The file only exists on an Omarchy install, so this is a no-op everywhere else.
local theme = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")
if not (vim.uv or vim.loop).fs_stat(theme) then
  return {}
end
return dofile(theme)
