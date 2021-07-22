export PATH=$HOME/bin:/usr/local/bin:$PATH
export ZSH="/home/tobi/.oh-my-zsh"

ZSH_THEME="avit"
HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="yyyy-mm-dd"
LANG="en_US.UTF-8"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  docker
  sudo
  history
  extract
  last-working-dir
  z
  asdf
)

source $ZSH/oh-my-zsh.sh

# User configuration
export MANPATH="/usr/local/man:$MANPATH"
export LANG=en_US.UTF-8
export EDITOR='/opt/nvim.appimage'
export ARCHFLAGS="-arch x86_64"
export SSH_KEY_PATH="~/.ssh/id_rsa"
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$HOME/.cache/rebar3/bin:$HOME/projects/diff-so-fancy/diff-so-fancy:/bin/identify:/usr/bin/identify:/bin/identify:/usr/bin/identify:$PATH"
export MASTER_PASSWORD_REQUIRED="False"
export PGPASSWORD="postgres"
export TERM="xterm-256color"

alias srcsrv="source .env && iex -S mix phx.server"
alias srctst="source .env && mix test"
alias gas="git add . && git status"
alias srcz="source ~/dotfiles/.zshrc"
alias srct="tmux source-file ~/dotfiles/.tmux.conf"
alias update-upgrade="sudo apt update && sudo apt upgrade"
alias clean-packages="sudo apt update && sudo apt autoremove && sudo apt autoclean"
alias nvim="/opt/nvim.appimage"
alias diff="git diff --staged --color-words"

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

neofetch

eval "$(cased-init -)"

fpath=(~/.zsh/completion $fpath)
