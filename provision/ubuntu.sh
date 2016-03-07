#!/bin/bash -e

lang_pack="ro"

remove_list=(
    unity-lens-shopping
    unity-scope-musicstores
    unity-scope-video-remote
)

install_list=(
    libmtp-common
    mtp-tools
    libmtp-dev
    libmtp-runtime
    libmtp9

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
    tig
    tmux
    vim
    vim-gtk
    cryptsetup

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
    ack-grep

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
    Desktop
    Documents Documente
    Downloads Descărcări
    Music Muzică
    Pictures Poze
    Public
    Templates Șabloane
    Videos Video
    examples.desktop
)

gconf2_values=(
    /apps/gnome-terminal/profiles/Default/scrollbar_position string hidden
    /apps/gnome-terminal/profiles/Default/use_system_font bool false
    /apps/gnome-terminal/profiles/Default/use_theme_background bool false
    /apps/gnome-terminal/profiles/Default/use_theme_colors bool false
    /desktop/gnome/url-handlers/magnet/command string '/usr/bin/transmission-gtk %s'
    /desktop/gnome/url-handlers/magnet/enabled bool true
    /apps/gnome-terminal/profiles/Default/bold_color_same_as_fg bool false
    /apps/gnome-terminal/profiles/Default/default_show_menubar bool false
    /apps/gnome-terminal/profiles/Default/font string 'Ubuntu Mono 11'
)

gsettings_values=(
    org.gnome.desktop.background picture-options 'none'
    org.gnome.desktop.background picture-uri ''
    org.gnome.desktop.background primary-color '#45a2570a4b04'
    org.gnome.desktop.background show-desktop-icons false
    org.gnome.desktop.interface cursor-theme 'DMZ-Black'
    org.gnome.desktop.interface document-font-name 'Sans 9'
    org.gnome.desktop.interface font-name 'Ubuntu 9'
    org.gnome.desktop.interface gtk-theme 'Radiance'
    org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 10'
    org.gnome.desktop.wm.preferences theme 'Adwaita'
    org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 9'
    org.gnome.gedit.preferences.editor scheme 'oblivion'
    org.gnome.gedit.preferences.editor use-default-font false
)

main() {
    subcommand_"$@"
}

subcommand_desktop_root() {
    add_ppas_and_update
    remove_packages
    install_packages
    install_non_system_packages
    post_process
}

subcommand_desktop_user() {
    set_options
    configure_dirs
}

add_ppas_and_update() {
    apt-get update

    apt-get install -y python-software-properties
    add-apt-repository -y ppa:chris-lea/node.js
    add-apt-repository -y ppa:bugs-launchpad-net-falkensweb/cool-retro-term

    wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- |
    sudo apt-key add -

    echo "deb http://download.virtualbox.org/virtualbox/debian trusty contrib" \
        > /etc/apt/sources.list.d/virtualbox.list

    apt-get update
}

remove_packages() {
    apt-get remove -y "${remove_list[@]}"
}

install_packages() {
    apt-get upgrade -y
    apt-get install "${install_list[@]}" -y --force-yes
    apt-get autoremove
}

install_non_system_packages() {
    npm install -g "${npm_packages[@]}"
}

post_process() {
    fc-cache -f -v
    gdk-pixbuf-query-loaders \
        > /usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache
}

set_options() {
    local i

    local a=("${gconf2_values[@]}")
    for (( i=0; i<"${#a[@]}"; i+=3)); do
        gconftool-2 --set "${a[i]}" --type "${a[i+1]}" "${a[i+2]}"
    done

    local a=("${gsettings_values[@]}")
    for (( i=0; i<"${#a[@]}"; i+=3)); do
        gsettings set "${a[i]}" "${a[i+1]}" "${a[i+2]}"
    done
}

configure_dirs() {
    cd

    # Delete annyoing home dir structure.
    rm -fr "${unnecessary_files[@]}"
    cd -

    # Create main dirs.
    mkdir -p data eth pro

    # Create backups dir.
    mkdir -p data/backup
}

main "$@"
