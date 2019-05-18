#!/bin/bash

cd ~
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# install plugins
cd .oh-my-zsh/custom/plugins

git clone https://github.com/junegunn/fzf.git
git clone https://github.com/Treri/fzf-zsh.git
git clone https://github.com/zsh-users/zsh-autosuggestions.git
git clone https://github.com/zsh-users/zsh-completions


