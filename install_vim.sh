#!/bin/bash

sudo apt update
sudo apt install vim -y

git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh
