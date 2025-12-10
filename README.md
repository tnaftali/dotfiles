# 🏠 Dotfiles

My personal configuration files for macOS development environment.

## 📁 What's Included

### Core Configuration Files
- **`.zshrc`** - Zsh shell configuration with Oh My Zsh, aliases, and custom functions
- **`.tmux.conf`** - Tmux configuration with Catppuccin theme and vim-style navigation
- **`.gitconfig`** - Git configuration with diff tools and color settings
- **`init.vim`** - Neovim configuration with plugins, key mappings, and Lua setup
- **`.aerospace.toml`** - AeroSpace window manager configuration

### Application Configs
- **`ghostty.config`** - Ghostty terminal emulator settings
- **`settings.json`** - VS Code/Cursor editor settings
- **`keybindings.json`** - VS Code/Cursor custom key bindings

### Archive
- **`archive/`** - Legacy configuration files for reference
  - **`archive/linux/`** - Linux-specific configs (i3, X11, etc.)
  - **`archive/install.sh`** - Old installation script
  - **`archive/kitty.conf`** - Previous Kitty terminal config
  - **`archive/vim.md`** - Vim cheat sheet and notes

## 🛠 Tech Stack

- **Shell**: Zsh with Oh My Zsh
- **Terminal**: Ghostty
- **Editor**: Neovim + VS Code/Cursor
- **Multiplexer**: Tmux
- **Window Manager**: AeroSpace (macOS)
- **Theme**: Catppuccin (consistent across all apps)
- **Font**: Fira Code Nerd Font

## 🚀 Quick Setup

### Prerequisites
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install essential tools
brew install git zsh tmux neovim
```

### Installation
```bash
# Clone the repository
git clone https://github.com/tnaftali/dotfiles.git ~/dotfiles

# Create symbolic links (backup existing files first!)
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/.aerospace.toml ~/.aerospace.toml
ln -sf ~/dotfiles/ghostty.config ~/.config/ghostty/config

# VS Code/Cursor settings (adjust path as needed)
ln -sf ~/dotfiles/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
ln -sf ~/dotfiles/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
```

### Post-Installation
```bash
# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install Tmux Plugin Manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Install Neovim plugins (open nvim and run)
:PlugInstall

# Reload shell
source ~/.zshrc
```

## 🎨 Features

### Zsh Configuration
- **Oh My Zsh** with custom theme and plugins
- **Aliases** for development workflows (Git, Elixir/Phoenix, etc.)
- **Custom functions** including Git worktree helper
- **Node Version Manager** integration
- **History management** with Atuin

### Tmux Setup
- **Catppuccin theme** for beautiful aesthetics
- **Vim-style navigation** with seamless Neovim integration
- **Custom key bindings** with Ctrl+S prefix
- **Smart pane management** and resizing

### Neovim Configuration
- **Modern plugin management** with vim-plug
- **LSP support** via COC.nvim
- **Fuzzy finding** with Telescope
- **Git integration** with Fugitive and LazyGit
- **Syntax highlighting** with Treesitter

### VS Code/Cursor
- **Consistent theming** with Catppuccin
- **Vim keybindings** for modal editing
- **Custom shortcuts** optimized for development
- **Terminal integration** matching system setup

## 🔧 Customization

### Adding New Configurations
1. Add your config file to the repository
2. Create a symbolic link: `ln -sf ~/dotfiles/your-config ~/.your-config`
3. Update this README with the new file

### Modifying Existing Configs
All configuration files are organized with clear sections and comments. Look for section headers like:
```
# ── Section Name ─────────────────────────────────────────────────────────────
```

## 📝 Notes

- **Backup first**: Always backup your existing dotfiles before symlinking
- **Path adjustments**: Update paths in configs to match your username/setup
- **Sensitive data**: No passwords or API keys are stored in these configs
- **Cross-platform**: Main configs work on macOS; Linux configs are archived

## 🤝 Contributing

Feel free to fork this repository and adapt it for your own use. If you find improvements or fixes, pull requests are welcome!

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
