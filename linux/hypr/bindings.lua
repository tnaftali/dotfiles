-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle tobi.emojis")

-- Bitwarden picker (~/.local/bin/bw-menu) instead of the 1Password launcher.
hl.unbind("SUPER + SHIFT + SLASH")
o.bind("SUPER + SHIFT + SLASH", "Passwords", "bw-menu")

-- Emoji picker on the stock background-switcher key.
hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + SPACE", "Emojis", "omarchy-shell shell toggle tobi.emojis")

-- Screenshot on ALT+TAB, replacing the stock "focus next window" and "reveal on top".
hl.unbind("ALT + TAB")
o.bind("ALT + TAB", "Screenshot", "omarchy-capture-screenshot")

-- SUPER+F toggles floating/tiling (stock: full screen; SUPER+CTRL+F still does tiled full screen).
hl.unbind("SUPER + F")
o.bind("SUPER + F", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- Things (own GTK app, app id io.github.tobi.Things) opens as a floating window.
o.window("io.github.tobi.Things", { float = true, center = true })

-- Tasks web app: more see-through than the default-opacity preset (lower = more transparent).
o.window("brave-tnaftali.github.io__tasks_-Default", { opacity = "0.8 0.7" })

-- Quick capture bar (Things-style): a resident Quickshell daemon (autostart.lua); Enter sends the text to the Tasks inbox.
o.bind("ALT + X", "Quick capture", hl.dsp.global("task-capture:toggle"))

-- Stock launch keys for apps that were removed (Docker, Obsidian, Google Messages).
hl.unbind("SUPER + SHIFT + D")
hl.unbind("SUPER + SHIFT + O")
hl.unbind("SUPER + SHIFT + CTRL + G")

-- UpNote on ALT+B, as a floating window.
o.bind("ALT + B", "UpNote", "/home/tobi/Projects/dotfiles/scripts/upnote-toggle")
o.window("upnote", { float = true, center = true })

-- AeroSpace-style ALT binds and app rules, from the dotfiles repo.
require("hypr.aerospace")
