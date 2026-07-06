# openshell — isolated agent sandboxes

Version-controlled config + workflow for running coding agents (codex / opencode /
claude) in **isolated, parallel** [OpenShell](https://github.com/NVIDIA/OpenShell)
sandboxes, one per agent-run, bootstrapped from a git repo.

## Layout

| Path | What |
|---|---|
| `bin/osh` | entrypoint: `setup`, `up`, `harvest`, `ls`, `rm` (on `$PATH`) |
| `openshell/mode` | architecture choice — `provider` (ollama via `inference.local`) |
| `openshell/setup.sh` | idempotent gateway + provider/inference configuration |
| `openshell/lib.sh` | shared helpers |
| `openshell/policy/allow-endpoints.txt` | package-registry hosts to allow for `--install` |
| `openshell/configs/` | per-agent endpoint configs (`opencode.json`, `pi/models.json`) uploaded at launch |
| `openshell/sandbox/Dockerfile` | custom image = base + pi (pi isn't in base; runtime npm can't cross the proxy) |

Install is already reproducible via `homebrew/Brewfile` (`tap "nvidia/openshell"` +
`brew "nvidia/openshell/openshell"`). This dir is stow-ignored; `bin/osh` reaches it
by absolute path. Generated secrets (gateway TLS/JWT, SQLite state) live under
`~/.config/openshell` and `~/.local/state/openshell` and are **never** committed.

## Model backend — `provider` mode

Ollama Cloud is registered as an OpenShell **openai-type provider** pointed at
`https://ollama.com/v1`; every sandbox reaches models through `https://inference.local`.
The API token stays on the host (in the provider record), never enters a sandbox, and
the sandbox needs no model egress. Switch models with a single
`openshell inference update --model <m>` (hot, ~5s).

- **codex** (`wire_api="responses"`), **opencode** (`opencode.json` provider), and
  **pi** (`~/.pi/agent/models.json`) are all validated against `glm-5.2:cloud`.
- **claude** speaks the Anthropic API — add an `anthropic`-type provider later
  (token via Doppler) and `inference set --provider anthropic` to use it.

The custom image (`openshell/sandbox/Dockerfile`) bakes pi in at build time — npm's
HTTP client can't traverse the sandbox's TLS-terminating egress proxy at runtime, but
Docker build uses normal internet. `osh setup` pre-builds it (Docker-cached after).

## Secrets — Doppler

The Ollama Cloud token is the only secret. Create a key at
`https://ollama.com/settings/keys`, then store it in the `sandcastle` Doppler project
(which already holds sandbox AI/github secrets), personal config:

```sh
doppler secrets set OLLAMA_API_KEY=<key> -p sandcastle -c dev_personal
```

`osh` defaults to `sandcastle` / `dev_personal` (override via `OSH_DOPPLER_PROJECT` /
`OSH_DOPPLER_CONFIG`). `setup.sh` reads it with `doppler secrets get --plain` and
registers it as the provider credential via an env-only lookup (never on argv).

## The review gate

Code only leaves a sandbox by passing through your local env first:

1. `osh up` makes a shallow bundle of the repo and the sandbox **clones from the
   bundle** — no GitHub credentials inside.
2. the agent commits to branch `agent/<sandbox>`.
3. `osh harvest <sandbox>` bundles just the new commits back, `git fetch`es them into
   your local clone, and shows the log + diffstat. **It never pushes.** You review and push.

This holds both structurally and by policy: OpenShell sandboxes **deny all egress by
default**, so GitHub is unreachable from inside (verified). `osh up --install` opens
*only* the package-registry hosts in `policy/allow-endpoints.txt`, bound to the network
binary — GitHub stays denied.

## Usage

```sh
osh setup                     # once (and after any config change)
osh up -a codex ~/dev/foo     # create sandbox, ingest repo (shallow), launch codex
osh up -a codex --install     # ...also run yarn/npm install (opens registry egress)
osh up -a codex --no-launch   # (from inside a repo) prepare only, in parallel
osh harvest <sandbox>         # bring the agent branch back to review (never pushes)
osh ls ; osh rm <sandbox>     # manage the fleet
```
