# dotfiles - getting started

```console
git clone https://github.com/brenodt/dotfiles.git
cd .dotfiles

# To see changes before they're made
stow --simulate .

# To create symlinks on parent directory
stow .

# To delete
stow --delete .
```

### Local ZSH Config

If there's customization you want ZSH to load on startup that is specific to this machine (stuff you don't want to commit into the repo), create `~/.env.sh` and put it in there. It will be loaded near the top of .zshrc.

### How this works

The configuration files are managed via [stow](https://www.gnu.org/software/stow/manual/).

The main addition is the system to auto-install dependencies on a fresh system, which
uses Ansible.

The structure is:
- Anything that needs to be ignored from symlinking gets added to the `.stow-local-config` file (keep in mind the proper rules for it: [link](https://www.gnu.org/software/stow/manual/stow.html#Types-And-Syntax-Of-Ignore-Lists))
- stow symlinks to the target directory (default is the parent) by keeping the same structure found in the root. This means the fs should mimic that of the $HOME

Once configuration is done, just run `stow .`

### How updating the homebrew dependencies works

There is a function called `brewrapper` in `zsh/aliases.zsh` which is used as an alias for `brew`.
Whenever you interface with `brew` - install, remove, update, tap, utap, and so on -
you are aliased to this function, that does:
1. execute your `brew` command
2. regenerates the `Brewfile` (see [brew bundle](https://github.com/Homebrew/homebrew-bundle))
3. uses the `Brewfile` to set the dependencies for Ansible (via the `install/brewdeps` script)

This means that maintaining the new dependencies you add/remove from brew is seamless.

Just remember to push the local changes to remote!

