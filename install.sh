#!/usr/bin/env bash
# Bootstrap this vimrc on a new machine.
set -e

echo "Backing up existing ~/.vimrc (if any) to ~/.vimrc.bak"
[ -f ~/.vimrc ] && cp ~/.vimrc ~/.vimrc.bak

echo "Symlinking .vimrc"
ln -sf "$(pwd)/.vimrc" ~/.vimrc

echo "Installing vim-plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Installing plugins (headless)"
vim +PlugInstall +qall

echo "Done. Open vim and run :LspInstallServer on a .py/.js/.vue file to set up language servers."
