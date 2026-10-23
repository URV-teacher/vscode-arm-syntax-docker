#!/usr/bin/env bash
# Downloads the assets of vscode-arm-syntax-docker into assets/.
#
# The download logic is the one shared by every component of the BMDE (download_lib.sh, copied from bmde: see it for
# the details). The external resources are listed in the documentation of bmde (docs/development/external-resources.md).
#
#   scripts/download_assets.sh [ASSET...]    (every asset by default)
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=download_lib.sh
source "${SCRIPT_DIR}/download_lib.sh" "$@"

# Downloads the latest release of the extension of the ARM assembly syntax of the course into the file $1
# shellcheck disable=SC2329  # Called through a function: source of asset
download_extension() {
  local repo=URV-teacher/arm-syntax-vscode-extension version
  version="$(download "https://api.github.com/repos/${repo}/releases/latest" /dev/stdout | grep '"tag_name"' \
    | cut -d '"' -f 4)" || return 1
  download "https://github.com/${repo}/releases/download/${version}/arm-syntax-vscode-extension-${version#v}.vsix" "$1"
}

# Visual Studio Code (latest version)
asset vscode.deb "" "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
# Extension of the ARM assembly syntax of the course and its install script, laid out as in its repository (latest
# version). docker-bake.hcl of bmde uses the checkout of the extension instead
asset arm-syntax-vscode-extension/src/install_extension.sh "" \
  "https://raw.githubusercontent.com/URV-teacher/arm-syntax-vscode-extension/main/src/install_extension.sh"
asset arm-syntax-vscode-extension/assets/arm-syntax-vscode-extension.vsix "" function:download_extension

exit "${failed}"
