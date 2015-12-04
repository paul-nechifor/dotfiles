#!/bin/bash

lang_pack="ro"

remove_list=(
  unity-lens-shopping
  unity-scope-musicstores
  unity-scope-video-remote
)

install_list=(
  # Terminal apps
  cmus
  weechat

  # Programming
  build-essential
  cloc
  git
  git-cola
  git-svn
  gitg
  golang
  ipython
  kompare
  linux-headers-$(uname -r)
  linux-headers-generic
  maven
  nasm
  netbeans
  nodejs
  openjdk-7-jdk
  python-jedi
  python-pip
  shellcheck
  subversion
  tidy
  tmux
  vim
  vim-gtk

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
  inotify-tools
  p7zip
  p7zip-full
  p7zip-rar
  scrot
  tree
  unrar
  xbacklight
  xdotool
  xsel

  # VPN
  bridge-utils
  network-manager-openvpn
  network-manager-openvpn-gnome
  openvpn

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
  vlc
  wicd-gtk
  xchm
  cool-retro-term

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

  # VirtualBox
  virtualbox-4.3
  dkms
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
  if [ "$(id -u)" != 0 ]; then
    echo "You are not root."
    exit 1
  fi
}

add_ppas_and_update() {
  apt-get update

  apt-get install -y python-software-properties
  add-apt-repository -y ppa:chris-lea/node.js
  add-apt-repository -y ppa:bugs-launchpad-net-falkensweb/cool-retro-term

  wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- |
  sudo apt-key add -

  echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" \
      >> /etc/apt/sources.list.d/virtualbox.list

  apt-get update
}

remove_packages() {
  apt-get remove -y "${remove_list[@]}"
}

install_packages() {
  apt-get upgrade
  apt-get install "${install_list[@]}"
}

configure_dirs() {
  cd

  # Delete annyoing home dir structure.
  rm -fr "${unnecessary_files[@]}"
  cd -

  # Create main dirs.
  mkdir data eth pro || true

  # Create backups dir.
  mkdir -p data/backup || true
}

set_options() {
  # Don't show desktop with Nautilus.
  gsettings set org.gnome.desktop.background show-desktop-icons false
}

install_non_system_packages() {
  npm install -g "${npm_packages[@]}"

  # tmuxinator
}

post_process() {
  fc-cache -f -v
}

main() {
  check_if_root

  add_ppas_and_update
  remove_packages
  install_packages
  install_non_system_packages

  configure_dirs
  set_options
  post_process
}

main
