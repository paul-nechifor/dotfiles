#!/bin/bash

# If you are sure you know your are doing install with:
# wget -q -O- 'https://github.com/paul-nechifor/dotfiles/raw/master/infect.sh' | sudo bash

wget -q 'https://github.com/paul-nechifor/dotfiles/archive/master.zip'
unzip -q master.zip
rm master.zip
bash dotfiles-master/install.sh
rm -fr dotfiles-master
. ~/.bashrc
