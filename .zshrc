######################################################################
# zsh profiling
PROFILE=false
if [[ "$PROFILE" == true ]]; then
  zmodload zsh/zprof # top of your .zshrc file
fi

######################################################################
# Settings not to be commited publicly
test -e "${HOME}/do_not_commit.zshrc" && source "${HOME}/do_not_commit.zshrc"

######################################################################
# init conda 
#[ -d /Users/yanick ] && . "/Users/yanick/anaconda3/etc/profile.d/conda.sh"

######################################################################
export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

export EDITOR='vim'
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`


######################################################################
# lf file manager
#
LFCD="$HOME/.config/lf/lfcd.sh" 
if [ -f "$LFCD" ]; then
    source "$LFCD"
fi

bindkey -s '^o' 'lfcd\n'  # zsh


######################################################################
# Pushover
# PUSH_OVER_APP_TOKEN and PUSH_OVER_APP_TOKEN are defined in do_not_commit.zshrc
notify() {notifiers pushover notify --user $PUSH_OVER_USER_KEY --token $PUSH_OVER_APP_TOKEN "$1"}


######################################################################
# oh-my-zsh config

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="powerlevel9k"
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs newline)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)
# POWERLEVEL9K_SHORTEN_DIR_LENGTH=10
# POWERLEVEL9K_SHORTEN_STRATEGY=truncate_middle
ZSH_THEME="frisk"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  docker
  docker-compose
  tmux
  z
  # pyenv
  fzf
  # fzf-zsh
  zsh-completions
  zsh-autosuggestions
  poetry
)

# Brew managed completions
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi


source $ZSH/oh-my-zsh.sh

######################################################################
# User configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=104'  # call to see all colors: spectrum_ls


# Reload the zsh-completions, only once a day. See https://medium.com/@dannysmith/little-thing-2-speeding-up-zsh-f1860390f92

autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C


######################################################################
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias dk=docker

# Store .dotfiles into Git. See https://www.atlassian.com/git/tutorials/dotfiles and https://github.com/yanickc/dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# exa - a modern replacement for 'ls'
[ -e /usr/local/bin/exa ] && alias ls="/usr/local/bin/exa --git" && alias ll="/usr/local/bin/exa -l --git --time-style long-iso" && alias la="ll -a"

alias please='sudo $(fc -ln -1)'

alias r=ranger
alias e=pycharm

alias start_black="blackd  &>/dev/null &"


######################################################################
# Fuzzy finder 'fzf'

# fcd - cd to selected directory
fcd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
} 

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fopen() {
  local out file key
  IFS=$'\n' out=($(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e))
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

######################################################################
# Docker utils
fdocker_prune() {
  docker rm $(docker ps -q -f 'status=exited')
  docker rmi $(docker images -q -f "dangling=true")
}

######################################################################
# Git utils

fgit_switch_branch() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

fgit_del_branch() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m)
  if [[ $branch ]]; then
      echo "About to delete UNMERGED branch:\n'$branch'"
      read -q "REPLY?Are you sure? (y/n)"
      echo ""
      if [[ "$REPLY" = "y" ]]; then
        git branch -D $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
      else
        echo "Aborting..."
      fi
  fi
}

fgit_del_merged_branch() {
  local branches branch
  branches=$(git branch -vv --merged) &&
  branch=$(echo "$branches" | fzf +m) &&
  git branch -d $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# tm - create new tmux session, or switch to existing one. Works from within tmux too. (@bag-man)
# `tm` will allow you to select your tmux session via fzf.
# `tm irc` will attach to the irc session (if it exists), else it will create it.

######################################################################
# tmux
tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}

######################################################################
# fzf fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# fd - Find any directory and cd to selected directory
fd() { local dir dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) && cd "$dir"}

######################################################################
# iterm2 integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

######################################################################
# zsh profiling
if [[ "$PROFILE" == true ]] ; then
  zprof # bottom of .zshrc
fi

######################################################################
# pyenv
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

######################################################################
# broot lets you explore directory trees and launch commands.                                                   ▐
# It's best used when launched as br.                                                                           ▐
# See https://dystroy.org/broot for a complete guide.
source /Users/yanick/Library/Preferences/org.dystroy.broot/launcher/bash/br

# Created by `userpath` on 2020-09-02 21:23:19
export PATH="$PATH:/Users/yanick/.local/bin"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/usr/local/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


