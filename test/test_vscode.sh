#!/usr/bin/env bash
# Tests that VS Code is installed.
set -Eeuo pipefail

code --version

# The helper of the sandbox of Chromium must be setuid root, or code aborts ("The SUID sandbox helper binary was found,
# but is not configured correctly")
vscode_dir="$(dirname "$(dirname "$(readlink -f "$(command -v code)")")")"
sandbox_mode="$(stat -c '%u %a' "${vscode_dir}/chrome-sandbox")"
if [ "${sandbox_mode}" != "0 4755" ]; then
  echo "${vscode_dir}/chrome-sandbox has owner and mode '${sandbox_mode}' instead of '0 4755'" >&2
  exit 1
fi
echo "VS Code OK"
