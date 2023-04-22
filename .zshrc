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

alias srcsrv="source .env && nvm use 16.16.0 && iex -S mix phx.server"
alias srctst="source .env && MIX_ENV=test mix test --color"
alias srctstbf="source .env && MIX_ENV=test mix test apps/betafolio/test --color"

alias gas="git add . && git status"
alias gs="git status"
alias gc="git checkout $1"
alias gp="git pull origin $1"
alias srcz="source ~/dotfiles/.zshrc"
alias srct="tmux source-file ~/dotfiles/.tmux.conf"
alias diff="git diff --staged --color-words"
alias list="exa --long --header --git --icons --all"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

neofetch

export NVM_DIR=~/.nvm
source $(brew --prefix nvm)/nvm.sh

. /opt/homebrew/opt/asdf/libexec/asdf.sh

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`
# export NODE_OPTIONS=--openssl-legacy-provider
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
chruby ruby-3.1.2

export PATH="/Users/tobi/.asdf/shims/elixir/:/Users/tobi/.asdf/shims/mix:/Users/tobi/.nvm/versions/node/v16.16.0/bin/yarn:/opt/homebrew/opt/openjdk/bin:/opt/homebrew/opt/openssl@1.1/bin:$PATH"
