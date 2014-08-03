#!/bin/bash

lang_pack="ro"
username="p"

remove_list=(
  unity-lens-shopping
  unity-scope-musicstores
  unity-scope-video-remote
)

install_list=(
  # Terminal apps
  cmus
  git
  git-cola
  git-svn
  gitg
  tmux
  vim
  vim-gtk

  # Programming
  build-essential
  cloc
  kompare
  linux-headers-`uname -r`
  linux-headers-generic
  nasm
  netbeans
  nodejs
  python-pip

  # Langauge pack
  language-pack-$lang_pack
  language-pack-gnome-$lang_pack
  language-pack-$lang_pack-base
  language-pack-gnome-$lang_pack-base

  # Fonts
  'ttf-*'

  # Utilities
  curl
  festival
  htop
  p7zip
  p7zip-full
  p7zip-rar
  scrot
  tree
  unrar
  xbacklight
  xdotool
  inotify-tools

  # Desktop
  gnome-shell
  gnome-tweak-tool
  i3

  # Apps
  audacity
  avidemux
  avidemux-cli
  avidemux-qt
  cheese
  easytag
  gimp
  inkscape
  kdenlive
  pidgin
  thunar
  thunar-archive-plugin
  thunar-media-tags-plugin
  tumbler-plugins-extra
  virtualbox
  vlc
  wicd-gtk
  xchm

  # Media things
  libav-tools
  gxine
  icedax
  id3tool
  lame
  libavdevice53
  libmad0
  libxine1-ffmpeg
  mencoder
  mpg321
  nautilus-script-audio-convert
  tagtool
  totem-mozilla
)

npm_packages=(
  bower
  coffee-script
  gulp
)

unnecessary_files=(
  Descărcări
  Desktop
  Documente
  Muzică
  Poze
  Public
  Șabloane
  Video
  examples.desktop
)

check_if_root() {
  if [ "`id -u`" != "0" ]; then
    echo "You are not root."
    exit 1
  fi
}

add_ppas_and_update() {
  apt-get update

  apt-get install -y python-software-properties
  add-apt-repository -y ppa:chris-lea/node.js

  apt-get update
}

remove_packages() {
  apt-get remove -y ${remove_list[@]}
}

install_packages() {
  apt-get upgrade
  apt-get install ${install_list[@]}
}

configure_dirs() {
  cd
  # Delete annyoing home dir structure.
  rm -fr "${unnecessary_files[@]}"
  cd -

  # Create backups dir.
  mkdir /home/backups 2>/dev/null
  chown $username:$username /home/backups
}

set_options() {
  # Don't show desktop with Nautilus.
  gsettings set org.gnome.desktop.background show-desktop-icons false
}

install_npm_packages() {
  npm install -g ${npm_packages[@]}
}

post_process() {
  fc-cache -f -v
}

main() {
  check_if_root

  add_ppas_and_update
  remove_packages
  install_packages
  install_npm_packages

  configure_dirs
  set_options
  post_process
}

main
