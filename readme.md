# Dotfiles

![cover](screenshot.png)

My personal Linux dotfiles.

## Usage

To install everything on a new computer:

    wget -q -O- https://github.com/paul-nechifor/dotfiles/raw/master/install.sh | bash -s - infect && . ~/.bashrc

To install everything on a new computer with a bad network that messes up
certificates:

    export ignore_security_because_why_not=true; wget --no-check-certificate -q -O- https://github.com/paul-nechifor/dotfiles/raw/master/install.sh | bash -s - infect && . ~/.bashrc

After that, you can reupdate everything with:

    infect

## License

MIT
