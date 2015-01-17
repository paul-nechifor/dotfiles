#!/bin/bash

# If you are sure you know what you're doing install with:
# wget -q -O- 'https://github.com/paul-nechifor/dotfiles/raw/master/infect.sh' | sudo bash

echo 'Downloading dotfiles archive...'
wget -q 'https://github.com/paul-nechifor/dotfiles/archive/master.zip'
unzip -q master.zip
rm master.zip

echo 'Starting installation...'
bash dotfiles-master/install.sh

echo 'Cleaning up...'
rm -fr dotfiles-master

echo 'Sourcing runcom...'
. ~/.bashrc

echo -e "\033[33m☢  Infection complete ☢ \033[0m\033[0;0m""]]]"
