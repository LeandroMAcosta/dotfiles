-- Display-focus hotkeys for a 3-monitor setup. Replaces AeroSpace: its window
-- model desynced from macOS on every click (clicking a window yanked focus to
-- a stale target), in 0.20.3 and 0.21.3 alike. Hammerspoon keeps no window
-- model, so it cannot disagree with macOS about anything.
--
-- Same chords as the AeroSpace setup: cmd+ctrl is the only modifier family
-- free of herdr (ctrl+shift, alt) and the terminals (plain cmd).
--
-- Logical row, index order:  1 built-in | 2 LG ULTRAWIDE | 3 bottom 1080p.
-- The bottom panel reports a generic name, so it is matched as "the remaining
-- screen" rather than by name.

-- CLI control: lets `hs -c "hs.reload()"` work, so config changes apply
-- without hunting the menu-bar icon.
require("hs.ipc")

local function row()
  local builtin, lg, rest = nil, nil, {}
  for _, s in ipairs(hs.screen.allScreens()) do
    local n = s:name() or ""
    if n:find("Built%-in") then
      builtin = s
    elseif n:find("LG") then
      lg = s
    else
      rest[#rest + 1] = s
    end
  end
  local r = {}
  if builtin then r[#r + 1] = builtin end
  if lg then r[#r + 1] = lg end
  for _, s in ipairs(rest) do r[#r + 1] = s end
  return r
end

local function indexOf(screen, r)
  for i, s in ipairs(r) do
    if s:id() == screen:id() then return i end
  end
  return 1
end

local function currentScreen()
  local w = hs.window.focusedWindow()
  return (w and w:screen()) or hs.mouse.getCurrentScreen()
end

local function focusScreen(target)
  if not target then return end
  for _, w in ipairs(hs.window.orderedWindows()) do
    if w:isStandard() and w:screen():id() == target:id() then
      w:focus()
      -- Warp the pointer too: macOS applies ctrl+left/right (Space switch) to
      -- the display under the mouse, so focus and Space-switching must agree.
      hs.mouse.absolutePosition(hs.geometry.rectMidPoint(w:frame()))
      hs.alert.show(target:name() or "display", 0.4)
      return
    end
  end
  -- Empty display: park the mouse there so at least new windows open on it.
  hs.mouse.absolutePosition(hs.geometry.rectMidPoint(target:fullFrame()))
  hs.alert.show((target:name() or "display") .. " (empty)", 0.4)
end

local function focusStep(delta)
  local r = row()
  local i = indexOf(currentScreen(), r) + delta
  if r[i] then focusScreen(r[i]) end
end

local function focusIndex(i)
  focusScreen(row()[i])
end

local function moveWindowTo(target)
  local w = hs.window.focusedWindow()
  if not (w and target) then return end
  w:moveToScreen(target, true, true)
  w:focus()
  hs.mouse.absolutePosition(hs.geometry.rectMidPoint(w:frame()))
  hs.alert.show("→ " .. (target:name() or "display"), 0.4)
end

local function moveStep(delta)
  local r = row()
  local i = indexOf(currentScreen(), r) + delta
  if r[i] then moveWindowTo(r[i]) end
end

local mod = { "cmd", "ctrl" }
local modShift = { "cmd", "ctrl", "shift" }

-- Walk the row.
hs.hotkey.bind(mod, "right", function() focusStep(1) end)
hs.hotkey.bind(mod, "left", function() focusStep(-1) end)
hs.hotkey.bind(mod, "l", function() focusStep(1) end)
hs.hotkey.bind(mod, "h", function() focusStep(-1) end)

-- Direct jumps: up = LG, down = bottom panel.
hs.hotkey.bind(mod, "up", function() focusIndex(2) end)
hs.hotkey.bind(mod, "down", function() focusIndex(3) end)
hs.hotkey.bind(mod, "k", function() focusIndex(2) end)
hs.hotkey.bind(mod, "j", function() focusIndex(3) end)

-- Send the focused window along the row, or straight to a display.
hs.hotkey.bind(modShift, "right", function() moveStep(1) end)
hs.hotkey.bind(modShift, "left", function() moveStep(-1) end)
hs.hotkey.bind(modShift, "up", function() moveWindowTo(row()[2]) end)
hs.hotkey.bind(modShift, "down", function() moveWindowTo(row()[3]) end)

hs.alert.show("display hotkeys loaded", 0.6)
