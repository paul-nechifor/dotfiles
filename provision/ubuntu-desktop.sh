#!/bin/bash

package_list=(
    # Terminal apps
    cmus
    git
    git-cola
    git-svn
    vim
    vim-gtk

    # Programming
    build-essential
    cloc
    linux-headers-`uname -r`
    linux-headers-generic
    nasm
    netbeans
    python-pip
    kompare

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

packages="${package_list[@]}"
sudo apt-get install $packages

# Delete annyoing dir structure.
rm -fr "${unnecessary_files[@]}"
