#!/bin/bash

# Install with:
# wget -O - 'https://github.com/paul-nechifor/dotfiles/raw/master/scripts/infect.sh' | sudo bash
# But don't do it! It destroys your previous dot files.

rm -fr dotfiles-master
wget 'https://github.com/paul-nechifor/dotfiles/archive/master.zip'
unzip master.zip
rm master.zip
cd dotfiles-master
bash scripts/install.sh
cd ..
. ~/.bashrc
