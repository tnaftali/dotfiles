-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Logitech device manager (MX Master buttons, DPI, SmartShift), tray only.
-- Symbolic icons: the bar tray recolors them to the bar text color.
o.exec_on_start("solaar --window=hide --battery-icons=symbolic")
-- Re-applies the gesture-button diversion if the mouse loses it.
o.exec_on_start("/home/tobi/Projects/dotfiles/scripts/solaar-keep-diverted")

-- Torrent client. Bound to the nordlynx VPN interface, so it idles until the VPN is up.
o.exec_on_start("qbittorrent")

-- Tailscale tray icon (connect/disconnect, peers, exit nodes).
o.exec_on_start("tailscale systray")

-- Google Drive sync status icon (syncing / ok / failed) for the gdrive-sync timer.
o.exec_on_start("/home/tobi/.local/bin/gdrive-tray")

-- Ghostcaret inline AI autocomplete. It is the input method, so omarchy-fcitx5.service stays disabled.
-- DMABUF off: WebKit crashes with a Wayland protocol error on NVIDIA otherwise.
o.exec_on_start("env WEBKIT_DISABLE_DMABUF_RENDERER=1 /home/tobi/.local/src/ghostcaret/target/release/ghostcaret")

-- Keep floating window sizes across restarts (persistent_size is in-memory only).
o.exec_on_start("/home/tobi/Projects/dotfiles/scripts/hypr-float-sizes.py")

-- Quick capture bar daemon (ALT+N toggles it; scripts/task-capture).
o.exec_on_start("qs -p /home/tobi/Projects/dotfiles/quickshell/task-capture")
