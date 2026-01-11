VSCODE_DIR=/bmde/vscode
echo PATH=$VSCODE_DIR/bin:$PATH >> $HOME/.bashrc

mkdir -p $VSCODE_DIR

apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
 && wget --no-check-certificate -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64" -O /tmp/vscode.tar.gz \
 && tar -xzvf /tmp/vscode.tar.gz -C $VSCODE_DIR \
 && rm /tmp/vscode.tar.gz

apt-get purge -y \
    wget \
    ca-certificates \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
