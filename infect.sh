#!/bin/bash

# If you are sure you know your are doing install with:
# wget -O- 'https://github.com/paul-nechifor/dotfiles/raw/master/scripts/infect.sh' | sudo bash

wget 'https://github.com/paul-nechifor/dotfiles/archive/master.zip'
unzip master.zip
rm master.zip
bash dotfiles-master/install.sh
rm -fr dotfiles-master
. ~/.bashrc
