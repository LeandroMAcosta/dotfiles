-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Live-reload files edited outside nvim (e.g. by a Claude Code session in
-- another terminal): poll for on-disk changes every second so buffers refresh
-- even while nvim is unfocused. gitsigns then marks the changed lines.
vim.o.autoread = true
vim.fn.timer_start(1000, function()
  if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
    vim.cmd("silent! checktime")
  end
end, { ["repeat"] = -1 })

-- Auto-open files an external tool (a Claude Code session) is editing: watch the
-- project recursively and point the current window at whichever file just changed.
-- Only jumps when it is safe: normal mode, no unsaved changes in the current buffer.
local watch_ignore = { "/%.git/", "node_modules", "%.venv/", "__pycache__", "/dist/", "%.log$", "lazy%-lock" }
local watch_root = vim.fn.getcwd()
local watcher = vim.uv.new_fs_event()
if watcher then
  local pending = {}
  watcher:start(watch_root, { recursive = true }, function(err, fname)
    if err or not fname then
      return
    end
    pending[fname] = true
    vim.schedule(function()
      for name in pairs(pending) do
        pending[name] = nil
        local path = watch_root .. "/" .. name
        local ignored = false
        for _, pat in ipairs(watch_ignore) do
          if path:find(pat) then
            ignored = true
            break
          end
        end
        if
          not ignored
          and vim.fn.filereadable(path) == 1
          and vim.fn.mode() == "n"
          and vim.fn.getcmdwintype() == ""
          and not vim.bo.modified
        then
          vim.cmd.edit(vim.fn.fnameescape(path))
          vim.cmd("silent! checktime")
        end
      end
    end)
  end)
end
