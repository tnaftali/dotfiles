# Setup — instructions for an agent

Run these steps on a fresh machine (macOS or Linux/Omarchy). Do each step, then report what you linked, copied, or skipped.

`DOTFILES` = the directory that holds this file. `OS` = `uname -s` (`Darwin` or `Linux`).

## Rules

- Link with `ln -s SOURCE TARGET`. If `TARGET` is already a symlink, check it: right target → skip; wrong target → `rm` it, then relink. Never use `ln -sf` on a directory target: it creates a link inside the old link.
- `TARGET` exists as a real file or directory → do not replace it. Warn and continue.
- Create parent directories first (`mkdir -p`).
- Repo is public. Never commit secrets, work names, or machine paths.

## 1. Repo

```bash
git -C "$DOTFILES" config core.hooksPath githooks   # pre-commit blocks secrets and org details
```

## 2. Shell and editor links

| Source (in `$DOTFILES`) | Target | When |
|---|---|---|
| `.zshrc` | `~/.zshrc` | always |
| `.tmux.conf` | `~/.tmux.conf` | always |
| `.gitconfig` | `~/.gitconfig` | always |
| `tmux/` | `~/.tmux/scripts` | always. `.tmux.conf` calls the scripts from here. |
| `.aerospace.toml` | `~/.aerospace.toml` | `Darwin` only |
| `init.vim` | `~/.config/nvim/init.vim` | always |
| `ghostty.config` | `~/.config/ghostty/config` | always |
| `ghostty.linux.config` | `~/.config/ghostty/os.conf` | `Linux` only. `ghostty.config` loads it last. |

## 3. Herdr config (hardlink, not symlink)

`herdr-gpui` refuses a symlinked config. The `~/.config/herdr/` directory holds live sockets and logs, so link only the file.

```bash
mkdir -p ~/.config/herdr
ln -f "$DOTFILES/herdr.config.toml" ~/.config/herdr/config.toml
```

- `Linux` and `~/.config/herdr/config.toml` already exists → skip. The distro ships its own.
- An editor or `git` can replace the file and break the hardlink. Run `ln -f` again to fix it.

## 3b. Herdr app config (`Linux` only)

`herdr-app/` holds the Herdr app config: keys, settings, theme, the `my-main` layout, and the custom mods. Herdr writes its own state into `~/.config/herdr-app/` (`shared.json`, `view.json`, `layouts/.state/`, ...). Link only the entries below.

```bash
mkdir -p ~/.config/herdr-app/layouts
for f in keys.json settings.json themes layouts/my-main.json; do ln -s "$DOTFILES/herdr-app/$f" ~/.config/herdr-app/$f; done
"$DOTFILES/herdr-app/link-mods.sh"
```

- Config files and `themes`: symlinks. `TARGET` is a real file or directory (Herdr creates `themes/` on first start) → warn, do not replace. The user decides.
- Mods: hardlinks, made by `link-mods.sh`. Herdr 0.1.8 does not load svg files behind a symlinked mod folder.
- A `git pull` or an editor can replace a linked file and break the hardlink. Run `link-mods.sh` again to fix it.
- Never put stock Herdr mods (`workspace-chrome`, ...) in `herdr-app/mods/`. A Herdr update rewrites them.

## 4. Hyprland binds (`Linux` and `~/.config/hypr` exists)

```bash
ln -s "$DOTFILES/hypr/aerospace.lua" ~/.config/hypr/aerospace.lua
```

Append this to `~/.config/hypr/bindings.lua` if `require("hypr.aerospace")` is not already there:

```lua
-- AeroSpace-style ALT binds and app rules, from the dotfiles repo.
require("hypr.aerospace")
```

## 5. Plugin managers (clone only if the target is absent)

| Repo | Target |
|---|---|
| `https://github.com/ohmyzsh/ohmyzsh.git` | `${ZSH:-~/.oh-my-zsh}` |
| `https://github.com/zsh-users/zsh-syntax-highlighting.git` | `$ZSH/custom/plugins/zsh-syntax-highlighting` |
| `https://github.com/zsh-users/zsh-autosuggestions.git` | `$ZSH/custom/plugins/zsh-autosuggestions` |
| `https://github.com/tmux-plugins/tpm.git` | `~/.tmux/plugins/tpm` |

Use `git clone --depth 1`. For vim-plug, if `${XDG_DATA_HOME:-~/.local/share}/nvim/site/autoload/plug.vim` is absent, download it with `curl -fsSLo <path> --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim`.

## 6. Agent config

**`~/.agents`**
- `~/.agents` missing or a symlink → link `$DOTFILES/.agents` to `~/.agents`.
- `~/.agents` is a real directory → link per entry. Inside `skills/`, link per skill directory.

**Claude Code** (`~/.claude` also holds plugin files, so link per file, not per directory)
- `$DOTFILES/.agents/agents/*.md` → `~/.claude/agents/<name>.md`
- `$DOTFILES/.agents/commands` → `~/.claude/commands`
- `$DOTFILES/.claude/CLAUDE.md` → `~/.claude/CLAUDE.md`
- `$DOTFILES/.claude/RTK.md` → `~/.claude/RTK.md`
- `$DOTFILES/.claude/settings.local.json` → `~/.claude/settings.local.json` (skip if the source is missing; it is gitignored)
- `$DOTFILES/.claude/hooks/*` (files only) → `~/.claude/hooks/<name>`
- `$DOTFILES/.agents/skills/*/` → `~/.claude/skills/<name>`
- **Copy, do not link**, only if absent: `$DOTFILES/.claude/settings.json` → `~/.claude/settings.json`. Claude Code rewrites it at runtime with internal host names, and this repo is public.

**Codex** — copy only if absent. Codex rewrites `config.toml`, and the two configs are meant to diverge.
- `$DOTFILES/.codex/AGENTS.md` → `~/.codex/AGENTS.md`
- `$DOTFILES/.codex/config.toml` → `~/.codex/config.toml`

## 7. Verify

- `ls -l ~/.zshrc ~/.tmux.conf ~/.claude/CLAUDE.md` shows links into `$DOTFILES`.
- `tmux source-file ~/.tmux.conf` prints no error.
- `zsh -ic exit` prints no error.
