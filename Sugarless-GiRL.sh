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

    if ! grep -Fqx 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    export GOROOT="$home/go-sdk"
    go_version=$("$home/go-sdk/bin/go" version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    required_go_version="1.27.3"

    if [[ -z "$go_version" ]] || [[ "$(printf '%s\n' "$go_version" "$required_go_version" | sort -V | tail -n1)" != "$go_version" ]]; then
        echo "go.dev go$required_go_version.linux-amd64.tar.gz"

        wget -q https://go.dev/dl/go1.27.3.linux-amd64.tar.gz -O /tmp/go.tar.gz || { echo "see https://go.dev/doc/install"; exit 1; }
        rm -rf "$home/go-sdk" 2>/dev/null
        mkdir -p "$home/go-sdk"
        tar -C "$home/go-sdk" --strip-components=1 -xzf /tmp/go.tar.gz || { echo "see https://go.dev/doc/install"; exit 1; }
        rm -rf /tmp/go.tar.gz
    fi

    go_version=$("$home/go-sdk/bin/go" version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    if [[ -z "$go_version" ]] || [[ "$(printf '%s\n' "$go_version" "$required_go_version" | sort -V | tail -n1)" != "$go_version" ]]; then
        echo "see https://go.dev/doc/install"
        exit 1
    fi

    if ! grep -Fqx 'export GOROOT="$HOME/Sugarless-GiRL/Sugarless-GiRL/go-sdk"' ~/.bashrc; then
        echo 'export GOROOT="$HOME/Sugarless-GiRL/Sugarless-GiRL/go-sdk"' >> ~/.bashrc
    fi
    if ! grep -Fqx 'export GOPATH="$GOROOT/Sugarless-GiRL"' ~/.bashrc; then
        echo 'export GOPATH="$GOROOT/Sugarless-GiRL"' >> ~/.bashrc
    fi
    if ! grep -Fqx 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' >> ~/.bashrc
    fi

    export GOROOT="$home/go-sdk"
    export GOPATH="$GOROOT/Sugarless-GiRL"
    export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
    mkdir -p "$GOPATH/bin" "$GOPATH/src" "$GOPATH/pkg"

    "$GOROOT/bin/go" install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    "$GOROOT/bin/go" install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest
    "$GOROOT/bin/go" install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
    "$GOROOT/bin/go" install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
    "$GOROOT/bin/go" install -v github.com/projectdiscovery/urlfinder/cmd/urlfinder@latest
    "$GOROOT/bin/go" install github.com/projectdiscovery/katana/cmd/katana@latest
    "$GOROOT/bin/go" install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
    "$GOROOT/bin/go" install github.com/charmbracelet/glow@latest

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
