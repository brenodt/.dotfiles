# Custom OpenShell sandbox image = base:latest + tools not shipped in base.
# Built locally by `openshell sandbox create --from openshell/sandbox` (Docker
# layer-cached, so only the first build is slow). Build-time network is normal
# internet — NOT the sandbox egress proxy — so npm works here; installing pi at
# runtime does not, because npm's HTTP client chokes on the proxy's TLS MITM.
FROM ghcr.io/nvidia/openshell-community/sandboxes/base:latest

# pi (coding agent) — not in the base image. Install globally to /usr as root.
USER root
RUN npm install -g @mariozechner/pi-coding-agent \
 && npm cache clean --force

# Restore the sandbox user OpenShell expects (home /sandbox, non-root).
USER sandbox
