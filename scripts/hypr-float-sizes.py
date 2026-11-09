#!/usr/bin/env python3
"""Keep floating window sizes across restarts.

Hyprland's persistent_size lives in memory only. This daemon saves the size of
each floating window by class to ~/.local/state/hypr-float-sizes.json and
resizes new floating windows to the saved size when they open.
Jot saves its own geometry, so it is skipped.
"""
import json
import os
import socket
import subprocess
import threading
import time
from pathlib import Path

STATE = Path.home() / ".local/state/hypr-float-sizes.json"
SKIP = {"jot"}
POLL = 1.0
SETTLE = 1.5  # seconds after a restore: let the app finish its own resize before recording

sizes = json.loads(STATE.read_text()) if STATE.exists() else {}
pending = {}  # address -> time before which the size is not recorded (restore in flight)
lock = threading.Lock()


def clients():
    out = subprocess.run(["hyprctl", "clients", "-j"], capture_output=True, text=True).stdout
    return json.loads(out or "[]")


def resize(address, w, h):
    cmd = f'hl.dsp.window.resize({{ x = {w}, y = {h}, window = "address:{address}" }})'
    subprocess.run(["hyprctl", "dispatch", cmd], capture_output=True)


def restore(address, cls):
    # A window may float a moment after it opens, so retry briefly.
    for _ in range(10):
        time.sleep(0.2)
        for c in clients():
            if c["address"] == address and c["floating"]:
                with lock:
                    want = sizes.get(cls)
                if want and c["size"] != want:
                    resize(address, *want)
                break
        else:
            continue
        break
    with lock:
        pending[address] = time.time() + SETTLE


def record():
    while True:
        time.sleep(POLL)
        changed = False
        now = time.time()
        for c in clients():
            cls = c["class"]
            if not c["floating"] or not cls or cls in SKIP or not c["mapped"]:
                continue
            with lock:
                if now < pending.get(c["address"], 0):
                    continue
                if sizes.get(cls) != c["size"]:
                    sizes[cls] = c["size"]
                    changed = True
        if changed:
            with lock:
                STATE.parent.mkdir(parents=True, exist_ok=True)
                tmp = STATE.with_suffix(".tmp")
                tmp.write_text(json.dumps(sizes, indent=1))
                tmp.replace(STATE)


def main():
    threading.Thread(target=record, daemon=True).start()
    path = f"{os.environ['XDG_RUNTIME_DIR']}/hypr/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock"
    sock = socket.socket(socket.AF_UNIX)
    sock.connect(path)
    for line in sock.makefile():
        event, _, data = line.rstrip("\n").partition(">>")
        if event != "openwindow":
            continue
        address, _, rest = data.partition(",")
        parts = rest.split(",", 2)  # workspace, class, title
        cls = parts[1] if len(parts) == 3 else ""
        address = "0x" + address
        with lock:
            if cls in sizes:
                pending[address] = time.time() + 30  # hold until restore ends
        if cls and cls not in SKIP and cls in sizes:
            threading.Thread(target=restore, args=(address, cls), daemon=True).start()


if __name__ == "__main__":
    main()
