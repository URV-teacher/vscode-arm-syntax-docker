#!/usr/bin/env bash
set -Eeuo pipefail

# Logging, validation and graphical output (MODE, VNC_*) shared by the BMDE images (from the base image)
# shellcheck source=/dev/null
source /usr/local/lib/bmde/entrypoint.sh

setup_display

# VS Code opens the folder in the arguments (the working directory by default) and runs until its window is closed.
# Chromium's sandbox needs privileges that containers do not have
args=( "$@" )
if (( ${#args[@]} == 0 )); then
  args=( . )
fi
log "Starting VS Code: code ${args[*]}"
code --wait --no-sandbox --disable-gpu "${args[@]}"
