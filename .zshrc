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
export PATH="$HOME/gems/bin:$PATH"
export MASTER_PASSWORD_REQUIRED="False"

export PGPASSWORD="postgres"

export PATH="$HOME/.cache/rebar3/bin:$PATH"
export PATH="$HOME/projects/diff-so-fancy/diff-so-fancy:$PATH"

alias srcsrv="source .env && iex -S mix phx.server"
alias srctst="source .env && mix test"
alias clean-packages="sudo apt update && sudo apt autoremove && sudo apt autoclean"
alias gas="git add . && git status"
alias srcz="source ~/dotfiles/.zshrc"
alias srct="tmux source-file ~/dotfiles/.tmux.conf"
alias n="/opt/nvim.appimage"

undo_commit() {
  git reset --soft HEAD^$1
}

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

neofetch

fpath=(~/.zsh/completion $fpath)
