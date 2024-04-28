# ALIASES -------------------------------------------------------------
alias dots='cd ~/.dotfiles/'

alias vi='nvim'
alias vim='nvim'

alias c='clear'
alias so='source ~/.zshrc'

alias l='exa -lah'
alias ls=exa
alias sl=exa

alias javahome='/usr/libexec/java_home'

alias sa='alias | fzf'

alias brew='brewrapper'

# K8S ALIASES ---------------------------------------------------------
alias kcl='kubectl'
alias kcx='kubectx'

# GIT ALIASES ---------------------------------------------------------
alias gc='git commit --verbose'
alias gco='git checkout'
alias ga='git add'
alias gst='git rev-parse --git-dir > /dev/null 2>&1 && git status || ls'
alias grp='git remote prune origin'
alias gff='grp && git pull --ff-only'
alias gmc='git merge --continue'
alias grc='git rebase --continue'
alias gp='git push'
alias gpsu='git push --set-upstream origin $(git branch --show-current)'
alias gundo='git reset --soft HEAD~1'

# FUNCTIONS -----------------------------------------------------------
function take {
  mkdir -p $1
  cd $1
}

function brewrapper {
  local original_path="$(pwd)"
  local brew_path="$(whereis brew | cut -d ' ' -f2)"
  
  if [[ $@ =~ ^install\  ]] || [[ $@ =~ ^uninstall\  ]] || [[ $@ =~ ^tap\  ]]; then
    echo "Skipping Brewfile and ansible updates for 'brew $@'"
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

function psaux {
  local arg=$1

  ps aux | head -n1
  ps aux | grep "$arg" | grep -v grep
}

# Example usage:
# cv input_video.mp4
cv() {
  if [ $# -eq 0 ]; then
    echo "Usage: compress_video <input_filename>"
    return 1
  fi

  input_filename="$1"
  output_filename="${input_filename%.*}.mp4"

  while [ "$#" -gt 0 ]; do
    case "$1" in
      -o)
        shift
        output_filename="$1"
        shift
        ;;
      *)
        shift
        ;;
    esac
  done

  ffmpeg -i "$input_filename" -vf "scale=1280:-2:flags=lanczos" -c:v libx264  -preset slow -crf 21 "$output_filename"
}

# Runs the dotconfig installer so that configs are in sync; assumes .dotfiles repo to be in home
syncconfigs() {
  bash $HOME/.dotfiles/install/bootstrap.sh
}
