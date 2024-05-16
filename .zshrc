source_if_exists () {
    if test -r "$1"; then
        source "$1"
    fi
}

source_if_exists $HOME/.env.sh
source_if_exists $DOTFILES/zsh/aliases.zsh
source_if_exists /usr/local/etc/profile.d/z.sh
source_if_exists /opt/homebrew/etc/profile.d/z.sh

if type "direnv" > /dev/null; then
    eval "$(direnv hook zsh)"
fi

autoload -U zmv
autoload -U promptinit && promptinit
autoload -U colors && colors
autoload -Uz compinit && compinit

if test -z ${ZSH_HIGHLIGHT_DIR+x}; then
else
    source $ZSH_HIGHLIGHT_DIR/zsh-syntax-highlighting.zsh
fi

precmd() {
    source $DOTFILES/zsh/aliases.zsh
}

export VISUAL=nvim
export EDITOR=nvim
export PATH="$PATH:/usr/local/sbin:$DOTFILES/bin:$HOME/.local/bin"

# Key-bindings ----------------------------------------------------------------
# https://github.com/alacritty/alacritty/issues/1408
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# VIM MODE (http://dougblack.io/words/zsh-vi-mode.html) -----------------------
# bindkey -v
bindkey '^?' backward-delete-char

# function zle-line-init zle-keymap-select {
#     VIM_PROMPT="%{$fg[yellow]%}[% NORMAL]% %{$reset_color%}"
#     RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}"
#     zle reset-prompt
# }

# zle -N zle-line-init
# zle -N zle-keymap-select
# export KEYTIMEOUT=1
# END VIM MODE ----------------------------------------------------------------

#eval "$(lua ~/bin/z.lua --init zsh)"

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
# zinit snippet OMZP::git
# zinit snippet OMZP::sudo
# zinit snippet OMZP::archlinux
# zinit snippet OMZP::aws
# zinit snippet OMZP::kubectl
# zinit snippet OMZP::kubectx
# zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'

# Shell integrations
eval "$(fzf --zsh)"
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="/Users/brenodt/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/brenodt/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
