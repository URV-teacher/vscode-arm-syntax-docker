#!/usr/bin/env bash
# Installs Visual Studio Code into /URV/bmde/vscode, and its environment (PATH) into /etc/profile.d/bmde-vscode.sh.
# Standalone: can be run in an Ubuntu / Debian host, and is also used by the BMDE Docker images. Set BMDE_ROOT to
# install into another directory.
set -Eeuo pipefail

BMDE_ROOT="${BMDE_ROOT:-/URV/bmde}"
SUDO=""; if [ "$(id -u)" -ne 0 ]; then SUDO=sudo; fi
VSCODE_DIR="${BMDE_ROOT}/vscode"
VSCODE_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

${SUDO} apt-get update
${SUDO} apt-get install -y --no-install-recommends ca-certificates wget

# VS Code is extracted from the package of Microsoft into VSCODE_DIR. The package declares the dependencies of VS Code
# for each distribution, which are saved to install them when VS Code is already there
DEPENDS="${VSCODE_DIR}/bmde-depends"
if [ ! -x "${VSCODE_DIR}/bin/code" ]; then
  wget "${VSCODE_URL}" -O /tmp/vscode.deb
  extract_dir="$(mktemp -d)"
  dpkg-deb --extract /tmp/vscode.deb "${extract_dir}"
  ${SUDO} rm -rf "${VSCODE_DIR}"
  ${SUDO} mkdir -p "${BMDE_ROOT}"
  ${SUDO} mv "${extract_dir}/usr/share/code" "${VSCODE_DIR}"
  dpkg-deb --field /tmp/vscode.deb Depends | ${SUDO} tee "${DEPENDS}" > /dev/null
  rm -rf "${extract_dir}" /tmp/vscode.deb
fi
${SUDO} apt-get satisfy -y --no-install-recommends "$(cat "${DEPENDS}")"

${SUDO} tee /etc/profile.d/bmde-vscode.sh > /dev/null <<PROFILE
case ":\${PATH}:" in
  *":${VSCODE_DIR}/bin:"*) ;;
  *) export PATH="${VSCODE_DIR}/bin:\${PATH}" ;;
esac
PROFILE

echo "VS Code installed in ${VSCODE_DIR}. Open a new session or run: . /etc/profile.d/bmde-vscode.sh"
