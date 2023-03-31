# dotfiles

### How this works

Heavily inspired by [Andrew Burgess' dotfiles](https://github.com/andrew8088/dotfiles) for managing the symlinks using a `links.prop` file in each
folder.

The structure is:
- Each program that requires configuration gets a folder
- normal configurations are added, no need for special file naming (handled by `links.prop`)
- *REQUIRED* add a `links.prop` file with one entry per file that requires symlinking (e.g. "FILE1=$HOME/.FILE1")

Once configuration is done, just run the bootstrap script. The configuration is idempotent, and also gives the options to
override or backup configuration files that already are at the destination (pretty nice!).

#### Install

```sh
git clone <this-repo>
cd <this-repo>
./scripts/bootstrap.sh
```

### Local ZSH Config

If there's customization you want ZSH to load on startup that is specific to this machine (stuff you don't want to commit into the repo), create `~/.env.sh` and put it in there. It will be loaded near the top of .zshrc.
