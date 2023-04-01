# ALIASES -------------------------------------------------------------
alias vi='nvim'
alias vim='nvim'

alias c='clear'
alias so='source ~/.zshrc'

alias l='exa -lah'
alias ls=exa
alias sl=exa

alias sa='alias | fzf'

alias brew='brewrapper'

# GIT ALIASES ---------------------------------------------------------
alias gc='git commit --verbose'
alias gco='git checkout'
alias ga='git add'
alias grp='git remote prune origin'
alias gff='grp && git pull --ff-only'
alias gmc='git merge --continue'
alias grc='git rebase --continue'
alias gp='git push'
alias gpsu='git push --set-upstream origin $(git branch --show-current)'

# FUNCTIONS -----------------------------------------------------------
function take {
  mkdir -p $1
  cd $1
}

function brewrapper {
  local original_path="$(pwd)"
  local brew_path="$(whereis brew | cut -d ' ' -f2)"
  
  if [[ $@ =~ '-(h|-help)' ]]; then
    bash $brew_path $@
    return $?
  fi

  echo "Step 1. attempting to $1 the dependenc(y|ies)..."
  bash $brew_path $@

  echo ""
  echo "Step 2. updating Brewfile..."
  cd ~/.dotfiles/homebrew
  bash $brew_path bundle dump --force

  echo ""
  echo "Step 3. updating ansible's brew dependency definitions..."
  cd ../install
  ./brewdeps

  cd "$original_path"
  echo ""
  echo "Done!"
  echo "Don't forget to commit and push .dotfiles changes"
}
