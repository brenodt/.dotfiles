#!/bin/bash

xcode-select --install

# CLONE REPO

# Create symlinks
ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig

mkdir ~/.config/nvim && ln -s ~/.dotfiles/nvim/init.vim ~/.config/nvim/init.vim

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install brew packages
brew bundle --file ~/.dotfiles/Brewfile


# Install vim-plug (https://github.com/junegunn/vim-plug)
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Install Powerline fonts (https://github.com/powerline/fonts)
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh
# clean-up a bit
cd ..
rm -rf fonts

mkdir ~/.config/fontconfig && cp ~/.dotfiles/fontconfig/conf.d ~/.config/fontconfig

