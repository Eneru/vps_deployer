#!/bin/bash

sudo apt update
sudo apt install tmux -y

git clone https://github.com/gpakosz/.tmux.git
ln -s -f .tmux/.tmux.conf ~/.tmux.conf
cp .tmux/.tmux.conf.local ~/.
