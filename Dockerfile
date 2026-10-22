# Visual Studio Code with the extension of the ARM assembly syntax of the course. The installation is done by the
# scripts in src/ of this repository and of arm-syntax-vscode-extension (with the assets downloaded into assets/ by
# scripts/download_assets.sh), the same ones used to install them in a host.

# Base image of the BMDE images (docker-bake.hcl of bmde replaces this stage by the base image being built)
FROM aleixmt/bmde-base:latest AS bmde-base

# Install script of the extension and its latest release, laid out as in its repository, downloaded into assets/ by
# scripts/download_assets.sh (docker-bake.hcl of bmde uses the checkout of the extension instead)
FROM scratch AS extension
COPY assets/arm-syntax-vscode-extension/ /


FROM bmde-base

RUN bmde-install-display

# install_container_launcher.sh makes `code` run without the sandbox of Chromium, which containers cannot use. The full
# development environment of the BMDE copies /URV/bmde/vscode from this image, so it gets the same launcher
RUN --mount=type=bind,target=/component \
    /component/src/install_vscode.sh \
    && /component/src/install_container_launcher.sh \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 src/entrypoint.sh /entrypoint.sh

RUN useradd --create-home --uid 1000 --shell /bin/bash vscode \
    && mkdir -p /input
USER vscode
# Extensions are installed for the user
RUN --mount=type=bind,from=extension,target=/extension bash /extension/src/install_extension.sh
WORKDIR /input

ENTRYPOINT ["/entrypoint.sh"]
CMD []
