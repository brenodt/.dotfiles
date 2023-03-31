# dotfiles

#### Install

```sh
git clone <this-repo>
cd <this-repo>
./scripts/bootstrap.sh
```

### Local ZSH Config

If there's customization you want ZSH to load on startup that is specific to this machine (stuff you don't want to commit into the repo), create `~/.env.sh` and put it in there. It will be loaded near the top of .zshrc.

### How this works

Heavily inspired by [Andrew Burgess' dotfiles](https://github.com/andrew8088/dotfiles) for managing the symlinks using a `links.prop` file in each folder.

The main addition is the system to auto-install dependencies on a fresh system, which
uses Ansible.

The structure is:
- Each program that requires configuration gets a folder
- normal configurations are added, no need for special file naming (handled by `links.prop`)
- *REQUIRED* add a `links.prop` file with one entry per file that requires symlinking (e.g. "FILE1=$HOME/.FILE1")

Once configuration is done, just run the bootstrap script. The configuration is idempotent, and also gives the options to
override or backup configuration files that already are at the destination (pretty nice!).

### How updating the homebrew dependencies works

There is a function called `brewrapper` in `zsh/aliases.zsh` which is used as an alias for `brew`.
Whenever you interface with `brew` - install, remove, update, tap, utap, and so on -
you are aliased to this function, that does:
1. execute your `brew` command
2. regenerates the `Brewfile` (see [brew bundle](https://github.com/Homebrew/homebrew-bundle))
3. uses the `Brewfile` to set the dependencies for Ansible (via the `install/brewdeps` script)

This means that maintaining the new dependencies you add/remove from brew is seamless.

Just remember to push the local changes to remote!
