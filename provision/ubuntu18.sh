#!/bin/bash -e

lang_pack="ro"
username="$(getent passwd 1000 | cut -d: -f1)"
export DEBIAN_FRONTEND=noninteractive

remove_list=(
    unity-lens-shopping
    unity-scope-musicstores
    unity-scope-video-remote
)

install_list=(
    # openjdk-8-jdk
    # ttf-'*'
    audacity # Audio editor.
    bridge-utils # For networking.
    build-essential # Important for compiling packages.
    calibre # Ebook program.
    cheese # Webcam program.
    cloc # Counts lines of code.
    cmus
    cryptsetup
    curl
    dconf-editor
    dkms
    easytag # MP3 tag editor.
    festival
    gimp
    git
    git-cola
    git-svn
    gitg
    gnome-shell
    gnome-tweak-tool
    golang
    htop # Better than top.
    i3
    i3lock
    icedax
    id3tool
    imagemagick
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
    libmtp-common
    libmtp-dev
    libmtp-runtime
    libmtp9
    linux-headers-$(uname -r)
    linux-headers-generic
    lm-sensors
    maven
    mencoder
    mpg321
    mtp-tools
    nasm
    nautilus-script-audio-convert
    netbeans
    network-manager-openvpn
    network-manager-openvpn-gnome
    nodejs
    npm
    openvpn
    p7zip
    p7zip-full
    p7zip-rar
    pidgin
    python-jedi
    python-pip
    qutebrowser
    rxvt-unicode-256color
    scrot
    shellcheck
    silversearcher-ag
    subversion
    texlive-full
    thunar
    thunar-archive-plugin
    thunar-media-tags-plugin
    tidy
    tig
    tmux
    tree
    ttf-mscorefonts-installer
    tumbler-plugins-extra
    ubuntu-restricted-extras
    unrar
    vim
    vim-gtk
    virtualbox-guest-additions-iso
    virtualbox-qt
    vlc # Video player.
    wicd-gtk
    xbacklight
    xchm
    xdotool
    xsel
)

npm_packages=(
    coffee-script
    eslint
    gulp
)

pip_packages=(
    flake8
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

gsettings_values=(
    org.gnome.desktop.background picture-options 'none'
    org.gnome.desktop.background picture-uri ''
    org.gnome.desktop.background primary-color '#45a2570a4b04'
    org.gnome.desktop.background show-desktop-icons false
    org.gnome.desktop.interface cursor-theme 'DMZ-Black'
    org.gnome.desktop.interface document-font-name 'Sans 9'
    org.gnome.desktop.interface font-name 'Ubuntu 9'
    org.gnome.desktop.interface gtk-theme 'Radiance'
    org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 11'
    org.gnome.desktop.wm.preferences theme 'Adwaita'
    org.gnome.desktop.wm.preferences titlebar-font 'Ubuntu Bold 9'
    org.gnome.gedit.preferences.editor scheme 'oblivion'
    org.gnome.gedit.preferences.editor use-default-font false
)

main() {
    if [[ $1 ]]; then
        subcommand_"$1"
    else
        subcommand_desktop_root
    fi
}

subcommand_desktop_root() {
    add_ppas_and_update
    remove_packages
    preconfigure_packages
    install_packages
    install_non_system_packages
    switch_to_user
}

add_ppas_and_update() {
    apt-get update
}

remove_packages() {
    apt-get remove -y "${remove_list[@]}"
}

preconfigure_packages() {
    echo '
gdm3	gdm3/daemon_name	string	/usr/sbin/gdm3
gdm3	shared/default-x-display-manager	select	lightdm
libssl1.0.0	libssl1.0.0/restart-failed	error	
libssl1.0.0	libssl1.0.0/restart-services	string	
mathematica-fonts	mathematica-fonts/accept_license	boolean	true
mathematica-fonts	mathematica-fonts/http_proxy	string	
mathematica-fonts	mathematica-fonts/license	note	
openvpn	openvpn/create_tun	boolean	false
texlive-base	texlive-base/binary_chooser	multiselect	pdftex, dvips, dvipdfmx, xdvi
texlive-base	texlive-base/texconfig_ignorant	error	
ttf-mscorefonts-installer	msttcorefonts/accepted-mscorefonts-eula	boolean	false
ttf-mscorefonts-installer	msttcorefonts/baddldir	error	
ttf-mscorefonts-installer	msttcorefonts/dldir	string	
ttf-mscorefonts-installer	msttcorefonts/dlurl	string	
ttf-mscorefonts-installer	msttcorefonts/error-mscorefonts-eula	error	
ttf-mscorefonts-installer	msttcorefonts/present-mscorefonts-eula	note	
ttf-root-installer	ttf-root-installer/baddldir	error	
ttf-root-installer	ttf-root-installer/blurb	note	
ttf-root-installer	ttf-root-installer/dldir	string	
ttf-root-installer	ttf-root-installer/savedir	string	
wicd-daemon	wicd/users	multiselect
' | debconf-set-selections
}

install_packages() {
    apt-get install -y debconf-utils
    apt-get upgrade -y
    apt-get install "${install_list[@]}" -y
    apt-get autoremove
}

install_non_system_packages() {
    npm install -g "${npm_packages[@]}"
}

switch_to_user() {
    su "$username" -c "bash $BASH_SOURCE desktop_user"
}

subcommand_desktop_user() {
    set_options
    configure_dirs
    install_user_things
}

set_options() {
    local i

    local a=("${gsettings_values[@]}")
    for (( i=0; i<"${#a[@]}"; i+=3)); do
        gsettings set "${a[i]}" "${a[i+1]}" "${a[i+2]}"
    done
    tm 11
    tm gruv
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

install_user_things() {
    pip install -U --user "${pip_packages[@]}"
}

main "$@"
