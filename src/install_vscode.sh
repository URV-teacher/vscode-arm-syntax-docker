#!/usr/bin/env bash
# Installs Visual Studio Code into /URV/bmde/vscode, and its environment (PATH) into /etc/profile.d/bmde-vscode.sh.
# Can be run in an Ubuntu / Debian host from a checkout of the repository (after scripts/download_assets.sh), and is
# also used by the BMDE Docker images. Set BMDE_ROOT to install into another directory.
set -Eeuo pipefail

BMDE_ROOT="${BMDE_ROOT:-/URV/bmde}"
SUDO=""; if [ "$(id -u)" -ne 0 ]; then SUDO=sudo; fi
VSCODE_DIR="${BMDE_ROOT}/vscode"
VSCODE_DEB="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/../assets/vscode.deb"

${SUDO} apt-get update

# VS Code is extracted from the package of Microsoft into VSCODE_DIR. The package declares the dependencies of VS Code
# for each distribution, which are saved to install them when VS Code is already there
DEPENDS="${VSCODE_DIR}/bmde-depends"
if [ ! -x "${VSCODE_DIR}/bin/code" ]; then
  if [ ! -f "${VSCODE_DEB}" ]; then
    echo "${VSCODE_DEB} not found: download it with scripts/download_assets.sh" >&2
    exit 1
  fi
  extract_dir="$(mktemp -d)"
  dpkg-deb --extract "${VSCODE_DEB}" "${extract_dir}"
  ${SUDO} rm -rf "${VSCODE_DIR}"
  ${SUDO} mkdir -p "${BMDE_ROOT}"
  ${SUDO} mv "${extract_dir}/usr/share/code" "${VSCODE_DIR}"
  dpkg-deb --field "${VSCODE_DEB}" Depends | ${SUDO} tee "${DEPENDS}" > /dev/null
  rm -rf "${extract_dir}"
fi
${SUDO} apt-get satisfy -y --no-install-recommends "$(cat "${DEPENDS}")"

# The helper of the sandbox of Chromium must be setuid root, which the package of VS Code does on its installation
# (not on extraction), or code aborts. Also when VS Code was already there (e.g. copied from another image)
${SUDO} chown root:root "${VSCODE_DIR}/chrome-sandbox"
${SUDO} chmod 4755 "${VSCODE_DIR}/chrome-sandbox"

${SUDO} tee /etc/profile.d/bmde-vscode.sh > /dev/null <<PROFILE
case ":\${PATH}:" in
  *":${VSCODE_DIR}/bin:"*) ;;
  *) export PATH="${VSCODE_DIR}/bin:\${PATH}" ;;
esac
PROFILE

echo "VS Code installed in ${VSCODE_DIR}. Open a new session or run: . /etc/profile.d/bmde-vscode.sh"
