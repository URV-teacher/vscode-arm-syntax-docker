#!/usr/bin/env bash
# Makes the code command of VS Code (installed by install_vscode.sh) always run without the sandbox of Chromium, for
# the BMDE Docker images. The sandbox creates PID and network namespaces, which containers cannot do (even with
# chrome-sandbox setuid root), so a plain `code` aborts in them. Not for hosts, where the sandbox works: there VS Code
# keeps its own launcher. The launcher is renamed to code-launcher and code passes --no-sandbox to it.
set -Eeuo pipefail

BMDE_ROOT="${BMDE_ROOT:-/URV/bmde}"
BIN_DIR="${BMDE_ROOT}/vscode/bin"

if [ ! -f "${BIN_DIR}/code-launcher" ]; then
  mv "${BIN_DIR}/code" "${BIN_DIR}/code-launcher"
fi
cat > "${BIN_DIR}/code" <<'LAUNCHER'
#!/bin/sh
# The sandbox of Chromium needs namespaces that containers cannot create (see install_container_launcher.sh)
exec "$(dirname "$(readlink -f "$0")")/code-launcher" --no-sandbox "$@"
LAUNCHER
chmod 755 "${BIN_DIR}/code"

echo "code runs VS Code without the sandbox of Chromium (${BIN_DIR}/code-launcher is the launcher of VS Code)"
