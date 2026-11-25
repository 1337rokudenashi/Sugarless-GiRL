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
    local home="$HOME/Sugarless-GiRL/.pkg"
    local bash="$HOME/.local/bin/Sugarless-GiRL"
    path=$(realpath "$0")
    [[ "$path" != "$bash" ]] && mkdir -p "$HOME/.local/bin" && cp "$path" "$bash" && chmod +x "$bash"

    if ! grep -Fqx 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    fi

    export GOROOT="$home/go"
    go_version=$("$home/go/bin/go" version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    required_go_version="1.27.3"

    if [[ -z "$go_version" ]] || [[ "$(printf '%s\n' "$go_version" "$required_go_version" | sort -V | tail -n1)" != "$go_version" ]]; then
        echo "go.dev go$required_go_version.linux-amd64.tar.gz"

        wget -q https://go.dev/dl/go1.27.3.linux-amd64.tar.gz -O /tmp/go.tar.gz || { echo "see https://go.dev/doc/install"; exit 1; }
        rm -rf "$home/go" 2>/dev/null
        mkdir -p "$home/go"
        tar -C "$home/go" --strip-components=1 -xzf /tmp/go.tar.gz || { echo "see https://go.dev/doc/install"; exit 1; }
        rm -rf /tmp/go.tar.gz
    fi

    go_version=$("$home/go/bin/go" version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    if [[ -z "$go_version" ]] || [[ "$(printf '%s\n' "$go_version" "$required_go_version" | sort -V | tail -n1)" != "$go_version" ]]; then
        echo "see https://go.dev/doc/install"
        exit 1
    fi

    if ! grep -Fqx 'export GOROOT="$HOME/Sugarless-GiRL/.pkg/go"' ~/.bashrc; then
        echo 'export GOROOT="$HOME/Sugarless-GiRL/.pkg/go"' >> ~/.bashrc
    fi
    if ! grep -Fqx 'export GOPATH="$GOROOT/Sugarless-GiRL"' ~/.bashrc; then
        echo 'export GOPATH="$GOROOT/Sugarless-GiRL"' >> ~/.bashrc
    fi
    if ! grep -Fqx 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' >> ~/.bashrc
    fi

    export GOROOT="$home/go"
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

    if ! grep -Fqx 'export PATH="$HOME/.bun/bin:$PATH"' ~/.bashrc; then
        echo 'export PATH="$HOME/.bun/bin:$PATH"' >> ~/.bashrc
    fi

    if ! grep -Eq '^[[:space:]]*(function[[:space:]]+)?pi[[:space:]]*(\(\))?[[:space:]]*\{' ~/.bashrc; then
        echo 'function pi() {' >> ~/.bashrc
        echo '    bun run "$HOME/.bun/bin/pi" "$@"' >> ~/.bashrc
        echo '}' >> ~/.bashrc
    fi

    if ! bun run "$HOME/.bun/bin/pi" --version >/dev/null 2>&1; then
        echo "bun add -g --ignore-scripts @earendil-works/pi-coding-agent"
        if ! bun add -g --ignore-scripts @earendil-works/pi-coding-agent; then
            echo "see https://docs.pi.dev/latest"
            exit 1
        fi

        if ! bun run "$HOME/.bun/bin/pi" --version >/dev/null 2>&1; then
            echo "see https://docs.pi.dev/latest"
            exit 1
        fi
    fi

    echo "Sugarless-GiRL executed."
    echo ""
    echo "Burp MCP Server"
    echo "  $ burpsuite"
    echo "  mcp-server"
    echo "  http://127.0.0.1:9876"
    echo ""
    echo "Pi · Sugarless-GiRL"
    echo "  $ Sugarless-GiRL"
    echo ""
    echo "Docs"
    echo "  https://docs.pi.dev/latest"
    echo ""
    echo "Burp MCP must be active."

}
Sugarless_GiRL
source "$HOME/.bashrc"
cd "$HOME/Sugarless-GiRL" || exit 1
sleep 5
exec bun run "$HOME/.bun/bin/pi"
