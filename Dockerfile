# Visual Studio Code with the extension of the ARM assembly syntax of the course. The installation is done by the
# scripts of this repository and of arm-syntax-vscode-extension, the same ones used to install them in a host.

# Install script of the extension, from its repository (docker-bake.hcl of bmde uses the local checkout instead)
# Base image of the BMDE images (docker-bake.hcl of bmde replaces this stage by the base image being built)
FROM aleixmt/bmde-base:latest AS bmde-base

FROM scratch AS extension
ADD --chmod=755 https://raw.githubusercontent.com/URV-teacher/arm-syntax-vscode-extension/main/scripts/install_extension.sh \
    /scripts/install_extension.sh


FROM bmde-base

RUN bmde-install-display

RUN --mount=type=bind,target=/component \
    /component/scripts/install_vscode.sh \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 entrypoint.sh /entrypoint.sh

RUN useradd --create-home --uid 1000 --shell /bin/bash vscode \
    && mkdir -p /input
USER vscode
# Extensions are installed for the user
RUN --mount=type=bind,from=extension,target=/extension bash /extension/scripts/install_extension.sh
WORKDIR /input

ENTRYPOINT ["/entrypoint.sh"]
CMD []
