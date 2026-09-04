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

-- Follow the edits an external tool (a Claude Code session) makes: when a file
-- open in nvim is rewritten on disk, reload it, move the cursor onto the first
-- line that actually changed and flash the changed ranges.
--
-- Three hooks, because the piece that detects the change is not the piece that
-- knows what changed:
--   * the fs watcher below is only a fast trigger for `checktime`;
--   * BufReadPost/BufWritePost keep a snapshot of each buffer while it is in
--     sync with the file on disk, keeping the previous one alongside it;
--   * FileChangedShellPost fires after nvim has reloaded and does the actual
--     work, diffing the two snapshots.
-- Splitting it this way removes a race: the 1s poll above can reload a buffer
-- before the watcher runs, and by then the pre-change contents are gone. The
-- previous snapshot is what survives that, because an autoread reload fires
-- BufReadPre, BufReadPost and only then FileChangedShellPost — so by the time
-- the diff runs, the current snapshot already holds the *new* contents.
local group = vim.api.nvim_create_augroup("claude_follow_changes", { clear = true })
local ns = vim.api.nvim_create_namespace("claude_follow_changes")

-- Buffers larger than this are reloaded normally but not diffed, so a huge file
-- never parks a second copy of itself in memory.
local max_lines = 20000
local snapshots = {}
local previous = {}

vim.api.nvim_set_hl(0, "ClaudeChangeFlash", { link = "DiffAdd", default = true })

local function snapshot(buf)
  if not vim.api.nvim_buf_is_loaded(buf) or vim.bo[buf].buftype ~= "" then
    return
  end
  if vim.api.nvim_buf_line_count(buf) > max_lines then
    snapshots[buf], previous[buf] = nil, nil
    return
  end
  previous[buf] = snapshots[buf]
  snapshots[buf] = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
  group = group,
  callback = function(ev)
    snapshot(ev.buf)
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  group = group,
  callback = function(ev)
    snapshots[ev.buf], previous[ev.buf] = nil, nil
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function(ev)
    local buf = ev.buf
    -- BufReadPost already ran for this reload, so the pre-change contents are
    -- in `previous` and the fresh ones in `snapshots`.
    local before, after = previous[buf], snapshots[buf]
    if not before or not after then
      return
    end

    -- result_type = "indices" gives {start_a, count_a, start_b, count_b} per
    -- hunk; the _b side is the reloaded buffer.
    local hunks = vim.diff(table.concat(before, "\n"), table.concat(after, "\n"), {
      result_type = "indices",
      algorithm = "histogram",
    })
    if type(hunks) ~= "table" or #hunks == 0 then
      return
    end

    local first = hunks[1][3]
    -- A pure deletion reports count_b == 0 at the line *before* the removal, so
    -- clamp to a line that exists.
    first = math.max(1, math.min(first, vim.api.nvim_buf_line_count(buf)))

    -- Move the cursor inside every window already showing this buffer. Focus is
    -- deliberately left alone: a change in a background split scrolls into view
    -- without yanking you out of the window you are working in.
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_set_cursor(win, { first, 0 })
      vim.api.nvim_win_call(win, function()
        vim.cmd("normal! zz")
      end)
    end

    -- Flash the changed ranges. Deletions (count_b == 0) get the single line
    -- they collapsed onto.
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
    for _, hunk in ipairs(hunks) do
      local start_line = math.max(0, hunk[3] - 1)
      local end_line = hunk[4] > 0 and (start_line + hunk[4]) or (start_line + 1)
      vim.hl.range(buf, ns, "ClaudeChangeFlash", { start_line, 0 }, { end_line - 1, -1 }, {
        inclusive = true,
        timeout = 1000,
      })
    end
  end,
})

-- Fast trigger: watch the project recursively and run `checktime` on the buffer
-- backing whichever file just changed, which in turn fires the handler above.
-- A changed file that is NOT open gets opened in the current window, so an
-- external editor session (Claude Code) stays visible without a manual `:e`.
-- Bursts touching many files (a git checkout, a formatter sweep) only reload:
-- opening dozens of buffers would bury the one being worked on.
local watch_ignore = { "/%.git/", "node_modules", "%.venv/", "__pycache__", "/dist/", "%.log$", "lazy%-lock" }
local open_burst_cap = 3
local watcher, pending
local burst = {}

local function start_watcher(root)
  if watcher then
    watcher:stop()
  end
  watcher = vim.uv.new_fs_event()
  if not watcher then
    return
  end
  watcher:start(root, { recursive = true }, function(err, fname)
    if err or not fname then
      return
    end
    local path = root .. "/" .. fname
    for _, pat in ipairs(watch_ignore) do
      if path:find(pat) then
        return
      end
    end
    -- Debounce: a single save often arrives as several events (write, rename,
    -- attribute change), and an edit can touch many files at once. A bare
    -- `checktime` then reloads every stale buffer, so a multi-file edit lands
    -- each open buffer on its own change instead of racing for one window.
    burst[path] = true
    if pending then
      pending:stop()
    end
    pending = vim.defer_fn(function()
      local paths = vim.tbl_keys(burst)
      burst = {}
      if vim.fn.mode() ~= "n" or vim.fn.getcmdwintype() ~= "" then
        return
      end
      vim.cmd("silent! checktime")
      if #paths > open_burst_cap then
        return
      end
      for _, p in ipairs(paths) do
        if vim.fn.filereadable(p) == 1 and vim.fn.bufloaded(p) == 0 then
          vim.cmd("silent! edit " .. vim.fn.fnameescape(p))
        end
      end
    end, 80)
  end)
end

start_watcher(vim.fn.getcwd())

-- Follow `:cd` / `:tcd`, otherwise the watcher keeps pointing at the directory
-- nvim happened to start in.
vim.api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = function()
    start_watcher(vim.fn.getcwd())
  end,
})
