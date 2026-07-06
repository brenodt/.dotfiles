#!/usr/bin/env bash
# openshell/lib.sh — shared helpers for the `osh` workflow.
# Sourced by bin/osh and openshell/setup.sh. No side effects on source.

# --- logging (matches install/bootstrap.sh house style) ------------------------
osh_info()    { printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"; }
osh_user()    { printf "\r  [ \033[0;33m??\033[0m ] %s\n" "$1"; }
osh_success() { printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"; }
osh_warn()    { printf "\r\033[2K  [ \033[0;33mWARN\033[0m ] %s\n" "$1"; }
osh_fail()    { printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1" >&2; exit 1; }

# --- paths ---------------------------------------------------------------------
: "${DOTFILES:=$HOME/.dotfiles}"
OSH_DIR="$DOTFILES/openshell"
OSH_STATE="${XDG_STATE_HOME:-$HOME/.local/state}/osh"   # per-sandbox local metadata (base SHAs)

# --- guards --------------------------------------------------------------------
osh_require() {
  local missing=0 c
  for c in "$@"; do
    command -v "$c" >/dev/null 2>&1 || { osh_warn "missing required command: $c"; missing=1; }
  done
  [ "$missing" -eq 0 ] || osh_fail "install the missing command(s) above and retry"
}

osh_gateway_ok() {
  # Cheap reachability probe; the gateway is the brew service on 127.0.0.1:17670.
  openshell status >/dev/null 2>&1
}

# The docker socket the CLI must use for image builds. Unlike the gateway (fixed
# via gateway.env), the CLI's `--from <Dockerfile>` build talks to docker directly
# and would otherwise fail on the missing classic /var/run/docker.sock.
osh_docker_host() { docker context inspect --format '{{.Endpoints.docker.Host}}' 2>/dev/null; }

# The custom sandbox image (base + pi), baked at build time. `osh setup` builds and
# refreshes this stable tag; `osh up` creates from it directly (no per-run build),
# building here only if the tag is missing entirely (e.g. setup never ran).
OSH_IMAGE="${OSH_IMAGE:-osh-sandbox:latest}"
OSH_IMAGE_DIR="$OSH_DIR/sandbox"
osh_ensure_image() {
  command -v docker >/dev/null 2>&1 || return 0
  [ -f "$OSH_IMAGE_DIR/Dockerfile" ] || return 0
  : "${DOCKER_HOST:=$(osh_docker_host)}"; export DOCKER_HOST
  docker image inspect "$OSH_IMAGE" >/dev/null 2>&1 && return 0
  osh_info "building sandbox image $OSH_IMAGE (first time is slow; cached after)"
  docker build -q -t "$OSH_IMAGE" "$OSH_IMAGE_DIR" >/dev/null
}

# --- architecture mode ---------------------------------------------------------
# The one deliberate choice: how sandboxes reach the model.
#   provider  -> ollama.com registered as an OpenShell openai-provider; agents use inference.local
#   community -> `--from ollama`; in-sandbox ollama; `ollama launch`; token via -e OLLAMA_API_KEY
# Resolution order: $OSH_MODE env  >  $OSH_DIR/mode file  >  unset (error).
osh_mode() {
  if [ -n "${OSH_MODE:-}" ]; then printf '%s' "$OSH_MODE"; return 0; fi
  if [ -r "$OSH_DIR/mode" ]; then tr -d '[:space:]' < "$OSH_DIR/mode"; return 0; fi
  return 1
}

# --- naming --------------------------------------------------------------------
# Deterministic-ish sandbox name: <repo>-<agent>-<6hex>. Randomness varies by
# reading /dev/urandom (Date/rand-free callers can still pass an explicit id).
osh_sandbox_name() {
  local repo="$1" agent="$2" id="${3:-}"
  [ -n "$id" ] || id="$(head -c3 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  printf '%s-%s-%s' "$(basename "$repo")" "$agent" "$id"
}

# Resolve a git repo root from a path (default: cwd).
osh_repo_root() {
  local start="${1:-$PWD}"
  git -C "$start" rev-parse --show-toplevel 2>/dev/null \
    || osh_fail "not inside a git repository: $start"
}

# Detect the install command for a repo (echoes nothing if none matched).
osh_detect_install() {
  local repo="$1"
  if   [ -f "$repo/yarn.lock" ];         then echo "yarn install --immutable"
  elif [ -f "$repo/pnpm-lock.yaml" ];    then echo "pnpm install --frozen-lockfile"
  elif [ -f "$repo/package-lock.json" ]; then echo "npm ci"
  elif [ -f "$repo/package.json" ];      then echo "npm install"
  elif [ -f "$repo/Gemfile" ];           then echo "bundle install"
  elif [ -f "$repo/requirements.txt" ];  then echo "pip install -r requirements.txt"
  fi
}

# --- secrets (Doppler) ---------------------------------------------------------
# The Ollama Cloud API token, from the `sandcastle` project (purpose-built to hold
# sandbox AI-provider/github secrets). Defaults to the personal config; override
# with OSH_DOPPLER_PROJECT / OSH_DOPPLER_CONFIG. An exported OLLAMA_API_KEY wins.
# Explicit -p/-c so it never depends on the cwd-scoped Doppler mapping.
osh_ollama_token() {
  if [ -n "${OLLAMA_API_KEY:-}" ]; then printf '%s' "$OLLAMA_API_KEY"; return 0; fi
  osh_require doppler
  doppler secrets get OLLAMA_API_KEY --plain \
    -p "${OSH_DOPPLER_PROJECT:-sandcastle}" -c "${OSH_DOPPLER_CONFIG:-dev_personal}" 2>/dev/null
}
