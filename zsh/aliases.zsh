# ALIASES -------------------------------------------------------------
alias vi='nvim'
alias vim='nvim'

alias c='clear'
alias so='source ~/.zshrc'

alias l='exa -lah'
alias ls=exa
alias sl=exa

alias sa='alias | fzf'

# GIT ALIASES ---------------------------------------------------------
alias gc='git commit'
alias gco='git checkout'
alias ga='git add'
alias grp='git remote prune origin'
alias gff='grp && g pull --ff-only'
alias gmc='git merge --continue'
alias grc='git rebase --continue'

# FUNCTIONS -----------------------------------------------------------
function take {
  mkdir -p $1
  cd $1
}
