# dotfiles

```sh 
cd install && ./bootstrap.sh
```

### How this works

Heavily inspired by [Andrew Burgess' dotfiles](https://github.com/andrew8088/dotfiles) for managing the symlinks using a `links.prop` file in each
folder.

The structure is:
- Each program that requires configuration gets a folder
- normal configurations are added, no need for special file naming (handled by `links.prop`)
- *REQUIRED* add a `links.prop` file with one entry per file that requires symlinking (e.g. "FILE1=$HOME/.FILE1")

Once configuration is done, just run the bootstrap script. The configuration is idempotent, and also gives the options to
override or backup configuration files that already are at the destination (pretty nice!).
