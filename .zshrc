######################################################################
# zsh profiling
PROFILE=false
if [[ "$PROFILE" == true ]]; then
  zmodload zsh/zprof # top of your .zshrc file
fi

######################################################################
# init conda 
[ -d /Users/yanick ] && . "/Users/yanick/anaconda3/etc/profile.d/conda.sh"

######################################################################
export LC_ALL=en_US.UTF-8  
export LANG=en_US.UTF-8

export EDITOR='vim'

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
  pyenv
  fzf-zsh
  zsh-completions
  zsh-autosuggestions
)

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
[ -e /usr/local/bin/exa ] && alias ls="/usr/local/bin/exa --git" && alias ll="/usr/local/bin/exa -l --git" && alias la="/usr/local/bin/exa -al --git"


######################################################################
# Settings not to be commited publicly
test -e "${HOME}/do_not_commit.zshrc" && source "${HOME}/do_not_commit.zshrc"


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

tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}


######################################################################
# iterm2 integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


######################################################################
# zsh profiling
if [[ "$PROFILE" == true ]] ; then
  zprof # bottom of .zshrc
fi
