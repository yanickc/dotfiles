# dotfiles

A bare git repository to store dotfiles.

See https://www.atlassian.com/git/tutorials/dotfiles

# Installation

Add to .bashrc or .zshrc:
```
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
```

Then:
```
git clone --bare <git-repo-url> $HOME/.dotfiles
```

Set the flag showUntrackedFiles to no on this specific (local) repository:
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
config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .config-backup/{}
```


You're done, from now on you can now type config commands to add and update your dotfiles:
```
dotfiles status
dotfiles add .vimrc
dotfiles commit -m "Add vimrc"
dotfiles add .bashrc
dotfiles commit -m "Add bashrc"
dotfiles push
```
