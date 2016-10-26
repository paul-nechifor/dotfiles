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

- Don't show `X`es in `svn st` because there are no changes.

- Run `setxkbmap ro; xmodmap ~/.Xmodmap` every minute.

- Start `nm-manager` in i3.

- Add `sass-lint` to Syntastic

- Add an `ag-do` command which takes an `ag` selector and the rest is a command
  to run on all the files. For example this would be useful with `sed` rename
  commands.

- Use `grep` if `ack` or `ag` don't exist.

## License

MIT
