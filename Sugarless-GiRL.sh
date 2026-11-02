#!/bin/bash
[[ ! -x "$0" ]] && chmod +x "$0"

export LC_ALL=C

function Sugarless_GiRL() {
    local required_commands=(
        bash burpsuite sqlmap commix dalfox
    )
    local missing_commands=()

    for command_name in "${required_commands[@]}"; do
        if ! command -v "$command_name" >/dev/null 2>&1; then
            missing_commands+=("$command_name")
        fi
    done

    if (( ${#missing_commands[@]} > 0 )); then
        echo ""
        echo "Missing Sugarless-GiRL dependencies:"
        for command_name in "${missing_commands[@]}"; do
            echo "  - $command_name"
        done
        echo ""
        echo "Please install the dependencies listed above:"
        echo ""
        echo "Debian / Ubuntu / Kali Linux:"
        echo "  apt install -y ${missing_commands[*]}"
        echo ""
        echo "Root privileges may be required."
        exit 1
    fi

    local Sugarless_GiRL="$HOME/Sugarless-GiRL"
    local home="$HOME/Sugarless-GiRL/Sugarless-GiRL"
    local bash="$HOME/.local/bin/Sugarless-GiRL"
    path=$(realpath "$0")
    [[ "$path" != "$bash" ]] && mkdir -p "$HOME/.local/bin" && cp "$path" "$bash" && chmod +x "$bash"

    if ! grep -q "export PATH=\$HOME/.local/bin:\$PATH" ~/.profile; then
        echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.profile
    fi

    node_version=$(node -v 2>/dev/null | sed 's/v//')
    required_node_version="24.22.1"

    if [[ -z "$node_version" ]] || [[ "$(printf '%s\n' "$node_version" "$required_node_version" | sort -V | tail -n1)" != "$node_version" ]]; then
        echo "nodejs.org node-v$required_node_version-linux-x64.tar.xz"

        wget -q https://nodejs.org/dist/v24.22.1/node-v24.22.1-linux-x64.tar.xz -O /tmp/node.tar.xz || { echo "see https://nodejs.org/en/download"; exit 1; }
        rm -rf "$home/node" 2>/dev/null
        mkdir -p "$home/node"
        tar -C "$home/node" --strip-components=1 -xf /tmp/node.tar.xz || { echo "see https://nodejs.org/en/download"; exit 1; }
        rm -rf /tmp/node.tar.xz

        export PATH="$home/node/bin:$PATH"

        if ! grep -q "export PATH=\$HOME/Sugarless-GiRL/Sugarless-GiRL/node/bin:\$PATH" ~/.profile; then
            echo "export PATH=\$HOME/Sugarless-GiRL/Sugarless-GiRL/node/bin:\$PATH" >> ~/.profile
        fi
    fi
    
    go_version=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    required_go_version="1.27.3"

    if [[ -z "$go_version" ]] || [[ "$(printf '%s\n' "$go_version" "$required_go_version" | sort -V | tail -n1)" != "$go_version" ]]; then
        echo "go.dev go$required_go_version.linux-amd64.tar.gz"

        wget -q https://go.dev/dl/go1.27.3.linux-amd64.tar.gz -O /tmp/go.tar.gz || { echo "see https://go.dev/doc/install"; exit 1; }
        rm -rf "$home/go" 2>/dev/null
        mkdir -p "$home/go"
        tar -C "$home/go" --strip-components=1 -xzf /tmp/go.tar.gz || { echo "see https://go.dev/doc/install"; exit 1; }
        rm -rf /tmp/go.tar.gz

        export GOROOT="$home/go"
        export GOPATH="$home/go/env"
        export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

        if ! grep -q "export GOROOT=\$HOME/Sugarless-GiRL/Sugarless-GiRL/go" ~/.profile; then
            echo "export GOROOT=\$HOME/Sugarless-GiRL/Sugarless-GiRL/go" >> ~/.profile
        fi
        if ! grep -q "export GOPATH=\$HOME/Sugarless-GiRL/Sugarless-GiRL/go/env" ~/.profile; then
            echo "export GOPATH=\$HOME/Sugarless-GiRL/Sugarless-GiRL/go/env" >> ~/.profile
        fi
        if ! grep -q "export PATH=\$GOROOT/bin:\$PATH" ~/.profile; then
            echo "export PATH=\$GOROOT/bin:\$PATH" >> ~/.profile
        fi
    fi

    export GOPATH="$home/go/env"
    if [[ -x "$home/go/bin/go" ]]; then
        export GOROOT="$home/go"
        export PATH="$GOROOT/bin:$PATH"
    fi
    export PATH="$GOPATH/bin:$PATH"
    mkdir -p "$GOPATH/bin" "$GOPATH/src" "$GOPATH/pkg"

    if ! grep -q "export PATH=\$HOME/Sugarless-GiRL/Sugarless-GiRL/go/env/bin:\$PATH" ~/.profile; then
        echo "export PATH=\$HOME/Sugarless-GiRL/Sugarless-GiRL/go/env/bin:\$PATH" >> ~/.profile
    fi

    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
    go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    go install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
    go install github.com/projectdiscovery/katana/cmd/katana@latest
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    go install github.com/charmbracelet/glow@latest

    export PATH="$HOME/.bun/bin:$PATH"

    if ! command -v bun >/dev/null 2>&1; then
        if ! (set -o pipefail; curl -fsSL https://bun.sh/install | bash); then
            echo "see https://bun.sh/docs/installation"
            exit 1
        fi
    fi

    if ! command -v opencode >/dev/null 2>&1; then
        echo "bun install -g --trust @opencode/cli"
        bun install -g --trust @opencode/cli || { echo "see https://opencode.ai/docs"; exit 1; }
    fi

    mkdir -p "$HOME/Sugarless-GiRL" || { echo "see https://opencode.ai/docs"; exit 1; }
    cat <<'EOF' > "$HOME/Sugarless-GiRL/opencode.json"
{
  "$schema": "https://opencode.ai/config.json",
  "instructions": [
    "Sugarless-GiRL.md"
  ],
  "mcp": {
    "burp": {
      "type": "remote",
      "url": "http://127.0.0.1:9876",
      "enabled": true
    }
  }
}
EOF
    if [[ $? -ne 0 ]]; then
        echo "see https://opencode.ai/docs"
        exit 1
    fi

    echo ""
    echo "Sugarless-GiRL executed."
    echo ""
    echo "Model Context Protocol (MCP):"
    echo "  $ burpsuite"
    echo "  mcp-server"
    echo "  MCP at http://127.0.0.1:9876"
    echo "  $ opencode"
    echo ""
    echo "Burp MCP must be active."
    echo ""

}
if [[ -n $1 ]]; then
    Sugarless_GiRL
    exec "$@"
else
    [[ -z $1 ]] && Sugarless_GiRL
    [[ -z $1 ]] && exec bash -l
    exit 0
fi
