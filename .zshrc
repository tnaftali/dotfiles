# export PATH=$HOME/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.cache/rebar3/bin:$HOME/gems/bin:$PATH
export ZSH="/Users/tobi/.oh-my-zsh"

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
export EDITOR='nvim'
export ARCHFLAGS="-arch x86_64"
export SSH_KEY_PATH="~/.ssh/id_rsa"
# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export MASTER_PASSWORD_REQUIRED="False"
export PGPASSWORD="postgres"
export TERM="xterm-256color"

alias srcsrv="source .env && nvm use 10.15.3 && redis-server & iex -S mix phx.server"
alias srctst="source .env && MIX_ENV=test mix test --color"
alias srctstbf="source .env && MIX_ENV=test mix test apps/betafolio/test --color"
alias gas="git add . && git status"
alias srcz="source ~/dotfiles/.zshrc"
alias srct="tmux source-file ~/dotfiles/.tmux.conf"
alias update-upgrade="sudo apt update && sudo apt upgrade"
alias clean-packages="sudo apt update && sudo apt autoremove && sudo apt autoclean"
alias diff="git diff --staged --color-words"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

neofetch

eval "$(cased-init -)"

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

. /opt/homebrew/opt/asdf/libexec/asdf.sh
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`
# export NODE_OPTIONS=--openssl-legacy-provider
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.2
