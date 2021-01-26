# dotfiles

A bare git repository to store dotfiles.

# Installation

Excerpt from: https://www.atlassian.com/git/tutorials/dotfiles

Add to .bashrc or .zshrc:
```
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Then:
```
git clone --bare git@github.com:yanickc/dotfiles.git $HOME/.dotfiles
```

Set the flag showUntrackedFiles to `no` on this specific (local) repository:
```
dotfiles config --local status.showUntrackedFiles no
```

Checkout the file in your HOME:
```
dotfiles checkout
```



The step above might fail with a message like:
```
error: The following untracked working tree files would be overwritten by checkout:
    .bashrc
    .gitignore
Please move or remove them before you can switch branches.
Aborting
```

This is because your $HOME folder might already have some stock configuration files 
which would be overwritten by Git. The solution is simple: back up the files if you 
care about them, remove them if you don't care. I provide you with a possible rough 
shortcut to move all the offending files automatically to a backup folder:

```
mkdir -p .config-backup && \
dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```


You're done, from now on you can now type `dotfiles` commands to add and update your dotfiles:
```
dotfiles status
dotfiles add .vimrc
dotfiles commit -m "Add vimrc"
dotfiles add .bashrc
dotfiles commit -m "Add bashrc"
dotfiles push
```


# Installing  `oh-my-zsh`

```
bash .install-oh-my-zsh.sh
```

# Faster keyboard repeat rate

```
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -float 1
```

# Use Mac Keychain for SSH passphrases

Add to `~/.ssh/config`:
```
Host *
    UseKeychain yes
```

# brew and Mac software
https://brew.sh/
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

```
brew install wget

brew install git
brew install --cask sourcetree

brew install pyenv      # pyenv lets you easily switch between multiple versions of Python.
                        # See https://github.com/pyenv/pyenv#readme
#brew install python

brew install lf         # lf is a terminal file manager.
brew install httpie     # User-friendly cURL replacement (command-line HTTP client)
brew install watch      # Executes a program periodically, showing output fullscreen
brew install htop 
brew install glances 
brew install exa        # Modern replacement for 'ls'
brew install jq         # Lightweight and flexible command-line JSON processor
brew install notifiers  # Send notifications. See .zshrc : notify() function.
brew install git-delta  # A viewer for git and diff output. https://github.com/dandavison/delta
brew install bat        # A cat(1) clone with syntax highlighting and Git integration. 
brew install starship   # The minimal, blazing-fast, and infinitely customizable prompt for any shell! 

brew install gpg        # See https://docs.github.com/en/github/authenticating-to-github/managing-commit-signature-verification

# gpg-agent on Mac
brew install pinentry-mac
echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
killall gpg-agent

```

# brew cask
Brew cask is an extension to brew that allows management of graphical applications through the Cask project. 

```
brew install --cask docker
brew install --cask macvim
brew install --cask vnc-viewer
brew install --cask sourcetree 
brew install --cask visual-studio-code
brew install --cask jetbrains-toolbox
brew install --cask firefox
brew install --cask google-chrome
brew install --cask 1password
brew install --cask bitwarden
brew install --cask evernote
brew install --cask slack
brew install --cask dropbox
brew install --cask menumeters
brew install --cask itsycal
brew install --cask gpg-suite

# Personal VPN
brew install --cask purevpn

# wallpaper
brew install --cask satellite-eyes

# fonts
brew install --cask homebrew/cask-fonts/font-jetbrains-mono
brew install --cask homebrew/cask-fonts/font-cousine-nerd-font-mono
brew install --cask homebrew/cask-fonts/font-fantasquesansmono-nerd-font-mono
brew install --cask homebrew/cask-fonts/font-firacode-nerd-font-mono
brew install --cask homebrew/cask-fonts/font-iosevka-nerd-font-mono
brew install --cask homebrew/cask-fonts/font-monofur-nerd-font-mono
brew install --cask homebrew/cask-fonts/font-nova-mono
brew install --cask homebrew/cask-fonts/font-ibm-plex
brew install --cask homebrew/cask-fonts/font-input
```

# local dev tools
```

See https://docs.mongodb.com/manual/tutorial/install-mongodb-on-os-x/
brew tap mongodb/brew
brew install mongodb-community@4.4

brew install redis

# Postgres.app is a full-featured PostgreSQL installation packaged as a standard Mac app. It includes everything you 
# need to get started: we’ve even included popular extensions like PostGIS for geo data and plv8 for JavaScript.
# 
# Postgres.app has a beautiful user interface and a convenient menu bar item. You never need to touch the command line # to use it – but of course we do include all the necessary command line tools and header files for advanced users.

brew install --cask postgres

# - or without UI -
brew install postgres

```

# Other software
- Magnet - https://magnet.crowdcafe.com/index.html
- Amphetamine - https://itunes.apple.com/ca/app/amphetamine/id937984704?mt=12&ign-mpt=uo%3D4
- Spark mail - https://sparkmailapp.com/
- Menu World Time - https://apps.apple.com/ca/app/menu-world-time/id1446377255
- Keka - https://www.keka.io/en/

# Vim and Vundle installation
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

Then, in Vim: 
```
:PluginInstall
```

