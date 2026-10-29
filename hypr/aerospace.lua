-- AeroSpace-style window/workspace binds for Hyprland (Omarchy).
-- Mirrors .aerospace.toml. Linked to ~/.config/hypr/aerospace.lua by an agent following SETUP.md
-- and loaded from ~/.config/hypr/bindings.lua with require("hypr.aerospace").
-- Omarchy's SUPER binds stay active alongside these.

-- Focus / move
local directions = { H = { "l", "left" }, J = { "d", "down" }, K = { "u", "up" }, L = { "r", "right" } }
for key, dir in pairs(directions) do
  o.bind("ALT + " .. key, "Focus " .. dir[2], hl.dsp.focus({ direction = dir[1] }))
  o.bind("ALT + SHIFT + " .. key, "Swap window " .. dir[2], hl.dsp.window.swap({ direction = dir[1] }))
end

-- Workspaces on the home row
local workspace_keys = { "A", "S", "D", "F", "G", "Y", "U", "I", "O", "P" }
for workspace, key in ipairs(workspace_keys) do
  local name = tostring(workspace)
  o.bind("ALT + " .. key, "Switch to workspace " .. name, hl.dsp.focus({ workspace = name }))
  o.bind("ALT + SHIFT + " .. key, "Move window to workspace " .. name, hl.dsp.window.move({ workspace = name, follow = false }))
end

o.bind("ALT + COMMA", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.bind("ALT + PERIOD", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- Resize (code:20 = minus, code:21 = equal)
o.bind("ALT + code:20", "Shrink window", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
o.bind("ALT + code:21", "Grow window", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))

-- Split direction for the next window
o.bind("ALT + C", "Split horizontal", hl.dsp.layout("preselect r"))
o.bind("ALT + V", "Split vertical", hl.dsp.layout("preselect d"))

o.bind("ALT + SHIFT + RETURN", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- Omarchy's SUPER+T does the same; ALT+SHIFT+SPACE is the one in use.
hl.unbind("SUPER + T")
o.bind("ALT + SHIFT + SPACE", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

o.bind("ALT + SHIFT + SEMICOLON", "Reload Hyprland config", "hyprctl reload")
o.bind("ALT + SHIFT + T", "Terminal", { omarchy = "terminal" })
o.bind("ALT + SHIFT + B", "Browser", { omarchy = "browser" })

-- App → workspace
o.window("brave-origin", { workspace = "1" })
o.window("com.mitchellh.ghostty", { workspace = "2" })
o.window("[Ss]potify", { workspace = "3" })
o.window("DBeaver", { workspace = "4" })
-- "silent": opens on workspace 4 without switching to it (autostarts at login).
o.window("org.qbittorrent.qBittorrent", { workspace = "4 silent" })

-- Floating apps
o.window("(brave-web.whatsapp.com__-Default|brave-web.telegram.org__-Default|Bitwarden|1[Pp]assword|org.telegram.desktop|brave-calendar.google.com__calendar_u_0_r_week-Default)", { float = true })

-- Quick notes (Raycast Notes style): ~/Projects/jot, a native GPUI text
-- window, pinned to show on every workspace. SUPER+N opens it, or closes it if open. The app restores its own size
-- and position, so no size or center rule here.
o.window("jot", { float = true, pin = true })
o.bind("SUPER + N", "Notes", "/home/tobi/.local/bin/jot-toggle")

o.bind("ALT + R", "WhatsApp", "omarchy-launch-or-focus-webapp WhatsApp https://web.whatsapp.com/")

-- Floating windows reopen at the size they were last resized to.
o.window(".*", { persistent_size = true })

o.bind("ALT + SHIFT + C", "Center floating window", hl.dsp.window.center())

-- Mouse back/forward per app. Non-consuming, so other apps still get their
-- normal back/forward click.
--   Ghostty, Herdr: previous/next herdr workspace (alt+[ / alt+])
--   WhatsApp: previous/next chat (ctrl+alt+shift+[ / ])
-- Sent through Hyprland, not wtype: wtype types from its own keymap, so web
-- apps that match on the physical key never see the bracket.
local mouse_nav = {
  ["com.mitchellh.ghostty"] = { modifiers = { { "ALT", "Alt_L" } } },
  ["so.pen.herdr-gpui"] = { modifiers = { { "ALT", "Alt_L" } } },
  ["brave-web.whatsapp.com__-Default"] = {
    modifiers = { { "CTRL", "Control_L" }, { "ALT", "Alt_L" }, { "SHIFT", "Shift_L" } },
  },
}

-- Build the key events for one chord: modifiers down, key down/up, modifiers up.
local function chord_steps(modifiers, key)
  local steps, held = {}, {}
  for _, modifier in ipairs(modifiers) do
    table.insert(held, modifier[1])
    table.insert(steps, { mods = table.concat(held, " "), key = modifier[2], state = "down" })
  end
  local all = table.concat(held, " ")
  table.insert(steps, { mods = all, key = key, state = "down" })
  table.insert(steps, { mods = all, key = key, state = "up" })
  for index = #modifiers, 1, -1 do
    table.remove(held)
    table.insert(steps, { mods = table.concat(held, " "), key = modifiers[index][2], state = "up" })
  end
  return steps
end

local function run_steps(steps, index, delay)
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state(steps[index]))
    if steps[index + 1] then
      run_steps(steps, index + 1, 20)
    end
  end, { timeout = delay, type = "oneshot" })
end

-- macOS-style dead keys: ALT+E then a vowel types it with an acute accent,
-- ALT+N then n types ñ. Any other key cancels.
-- Typed as AltGr+letter from the real layout (us altgr-intl), not with wtype:
-- with the fcitx5 input method running, wtype's own keymap never reaches Brave.
local level3 = { "MOD5", "ISO_Level3_Shift" }
local function dead_key(name, trigger, description, keys)
  hl.define_submap(name, "reset", function()
    for _, key in ipairs(keys) do
      hl.bind(key, function()
        run_steps(chord_steps({ level3 }, key), 1, 1)
      end)
      hl.bind("SHIFT + " .. key, function()
        run_steps(chord_steps({ level3, { "SHIFT", "Shift_L" } }, key), 1, 1)
      end)
    end
    hl.bind("catchall", hl.dsp.submap("reset"))
  end)
  o.bind("ALT + " .. trigger, description, hl.dsp.submap(name))
end

dead_key("acute", "E", "Acute accent (then a/e/i/o/u)", { "A", "E", "I", "O", "U" })
dead_key("tilde", "N", "Tilde (then n)", { "N" })

-- MX Master gesture-button click, called by Solaar (~/.config/solaar/rules.yaml)
-- with `hyprctl eval 'mx_gesture_click()'`:
--   Brave:    close the tab (ctrl+w)
--   Ghostty:  close the herdr workspace (prefix ctrl+s, then shift+d)
--   elsewhere: close the window
function mx_gesture_click()
  local window = hl.get_active_window()
  local class = window and window.class or ""
  if class:find("^brave%-") then
    run_steps(chord_steps({ { "CTRL", "Control_L" } }, "W"), 1, 1)
  elseif class == "com.mitchellh.ghostty" then
    -- No separate modifier key presses: Ghostty reports the synthetic Shift_L
    -- press as a key event between the prefix and the "D".
    run_steps({
      { mods = "CTRL", key = "S", state = "down" },
      { mods = "CTRL", key = "S", state = "up" },
      { mods = "SHIFT", key = "D", state = "down" },
      { mods = "SHIFT", key = "D", state = "up" },
    }, 1, 1)
  else
    hl.dispatch(hl.dsp.window.close())
  end
end

local function mouse_nav_bind(button, key)
  hl.bind(button, function()
    local window = hl.get_active_window()
    local nav = window and mouse_nav[window.class]
    if nav then
      -- Start after the button click itself has reached the app.
      run_steps(chord_steps(nav.modifiers, key), 1, 150)
    end
  end, { non_consuming = true, release = true })
end

mouse_nav_bind("mouse:275", "bracketleft")
mouse_nav_bind("mouse:276", "bracketright")
