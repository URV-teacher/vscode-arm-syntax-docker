# vscode-arm-syntax-docker
Visual Studio Code in Docker with the extension of the syntax of the ARM assembly of the course
([arm-syntax-vscode-extension](https://github.com/URV-teacher/arm-syntax-vscode-extension)) already installed. It opens
the folder mounted in `/input`, showing its window on the host (`MODE=host`) or through VNC (`MODE=vnc`):

```shell
docker run --rm -v "$PWD:/input" -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY="$DISPLAY" \
  -v "$XAUTHORITY:/tmp/.docker.xauth:ro" -e XAUTHORITY=/tmp/.docker.xauth -e MODE=host aleixmt/vscode
```

## Build and installation
`scripts/install_vscode.sh` installs VS Code into `/URV/bmde/vscode`, with its environment (`PATH`) in
`/etc/profile.d/bmde-vscode.sh`, and the script of the extension installs it for the user. The image is built with
them, and they install VS Code and the extension in an Ubuntu / Debian host too. Test the installation with
`scripts/test_vscode.sh`. To build the image:

```shell
docker build -t aleixmt/vscode .
```
