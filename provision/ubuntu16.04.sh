#!/bin/bash -e

lang_pack="ro"

remove_list=(
    unity-lens-shopping
    unity-scope-musicstores
    unity-scope-video-remote
)

install_list=(
    ack-grep
    audacity
    bridge-utils
    build-essential
    cheese
    cloc
    cmus
    cryptsetup
    curl
    dkms
    easytag
    festival
    gimp
    git
    git-cola
    git-svn
    gitg
    gnome-shell
    gnome-tweak-tool
    golang
    gxine
    htop
    i3
    icedax
    id3tool
    inkscape
    inotify-tools
    ipython
    kdenlive
    kompare
    lame
    language-pack-$lang_pack
    language-pack-$lang_pack-base
    language-pack-gnome-$lang_pack
    language-pack-gnome-$lang_pack-base
    libav-tools
    libmad0
    linux-headers-$(uname -r)
    linux-headers-generic
    maven
    mencoder
    mpg321
    nasm
    nautilus-script-audio-convert
    netbeans
    network-manager-openvpn
    network-manager-openvpn-gnome
    nodejs
    npm
    openjdk-7-jdk
    openvpn
    p7zip
    p7zip-full
    p7zip-rar
    pidgin
    python-jedi
    python-pip
    scrot
    shellcheck
    subversion
    tagtool
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    tidy
    tig
    tmux
    tree
    ttf-'*'
    tumbler-plugins-extra
    unrar
    vim
    vim-gtk
    vlc
    wicd-gtk
    xbacklight
    xchm
    xdotool
    xsel
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
    if [[ $1 ]]; then
        subcommand_"$@"
        return
    fi
    subcommand_desktop_root
}

subcommand_desktop_root() {
    add_ppas_and_update
    remove_packages
    install_packages
    install_non_system_packages
}

subcommand_desktop_user() {
    set_options
    configure_dirs
}

add_ppas_and_update() {
    apt-get update
}

remove_packages() {
    apt-get remove -y "${remove_list[@]}"
}

install_packages() {
    apt-get upgrade -y
    apt-get install "${install_list[@]}" -y
}

install_non_system_packages() {
    npm install -g "${npm_packages[@]}"
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
