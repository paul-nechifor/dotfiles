#!/usr/bin/env python2

import subprocess
import sys

THEMES = {
    'solarized-ish-dark': [
        '002B36',
        '657B83',

        '063642',
        'D30102',
        '859900',
        'B58900',
        '268BD2',
        'D33682',
        '2AA198',
        'EEE8D5',

        '002B36',
        'CB4B16',
        '859900',
        'B58900',
        '268BD2',
        'D33682',
        '2AA198',
        'FDF6E3',
    ],
    'solarized-ish-light': [
        'FDF6E3',
        '536466',

        'EEE8D5',
        'D30102',
        '859900',
        'B58900',
        '268BD2',
        'D33682',
        '2AA198',
        '073642',

        'FDF6E3',
        'CB4B16',
        '859900',
        'B58900',
        '268BD2',
        'D33682',
        '2AA198',
        '002B36',
    ]
}

def gconf_set(path, type, value):
    subprocess.call(['gconftool-2', '--set', path, '--type', type, value])

def join(theme, a, b):
    return '#' + ':#'.join(theme[a:b])

def install_theme(theme):
    path = '/apps/gnome-terminal/profiles/Default'
    gconf_set(path + '/use_theme_background', 'bool', 'false')
    gconf_set(path + '/use_theme_colors', 'bool', 'false')
    gconf_set(path + '/background_color', 'string', join(theme, 0, 1))
    gconf_set(path + '/foreground_color', 'string', join(theme, 1, 2))
    gconf_set(path + '/palette', 'string', join(theme, 2, 18))

def main():
    install_theme(THEMES[sys.argv[1]])

if __name__ == '__main__':
    main()
