#!/bin/bash

sudo apt update

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.zshrc

nvm install 17.9.1
npm install -g grunt-cli
git clone https://github.com/gchq/CyberChef.git
cd CyberChef
npm install

# To run it, use grunt prod
