# This repository has been moved to [gitlab.com/paul-nechifor/dotfiles](http://gitlab.com/paul-nechifor/dotfiles).

Old readme:

# Dotfiles

![cover](screenshot.png)

My personal Linux dotfiles.

## Usage

To install everything on a new computer:

    sudo true; wget -q -O- https://github.com/paul-nechifor/dotfiles/raw/master/install.sh | bash -s - infect && . ~/.bashrc

To install everything on a new computer with a bad network that messes up
certificates:

    sudo true; export ignore_security_because_why_not=true; wget --no-check-certificate -q -O- https://github.com/paul-nechifor/dotfiles/raw/master/install.sh | bash -s - infect && . ~/.bashrc

After that, you can update everything with:

    infect

Locally, just run:

    sudo true; ./install.sh

## TODO

- Run `setxkbmap ro; xmodmap ~/.Xmodmap` every minute.

- Use https://github.com/mitsuhiko/unp .

- Start `nm-manager` in i3.

- Add `sass-lint` to Syntastic

- Use `grep` if `ack` or `ag` don't exist.

- Fix Syntastic conf.

- Use proselint in Syntastic.

- Compile Vim 8.

- Add a script for which program is using which port.

## License

MIT
