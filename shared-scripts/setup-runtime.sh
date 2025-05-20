#!/bin/bash
set -e

RUNTIME="$1"

echo "Setting up runtime: $RUNTIME"

# Detect OS
case "$(uname -s)" in
    Linux*)     OS=linux;;
    Darwin*)    OS=macos;;
    CYGWIN*|MINGW*|MSYS*) OS=windows;;
    *)          echo "Unsupported OS"; exit 1;;
esac

# Function to install packages based on OS
install_package() {
    local packages=("$@")
    case "$OS" in
        linux)
            sudo apt-get update
            sudo apt-get install -y "${packages[@]}"
            ;;
        macos)
            brew install "${packages[@]}"
            ;;
        windows)
            for package in "${packages[@]}"; do
                if [[ "$package" == *"go"* ]]; then
                    # Use chocolatey for Go on Windows
                    choco install golang --version=1.20.14 -y
                elif [[ "$package" == *"python"* ]]; then
                    # Use chocolatey for Python on Windows
                    choco install python --version=3.10 -y
                else
                    # Use chocolatey for other packages
                    choco install "$package" -y
                fi
            done
            ;;
    esac
}

case "$RUNTIME" in
  "yarn-berry")
    echo "Installing Yarn Berry..."
    corepack enable
    corepack prepare yarn@stable --activate
    echo "Installed yarn version:"
    yarn -v
    ;;
  "pnpm")
    echo "Installing pnpm..."
    corepack enable
    corepack prepare pnpm@stable --activate
    echo "Installed pnpm version:"
    pnpm -v
    ;;
  "go-1.20")
    echo "Installing Go 1.20..."
    # Install specific version if needed
    go install "golang.org/dl/go1.20.14@latest"
    "go1.20.14" download
    
    # Set up Go 1.20 as default
    export PATH="$HOME/go/bin:$PATH"
    export GOROOT="$HOME/sdk/go1.20.14"
    export PATH="$GOROOT/bin:$PATH"
    
    echo "Installed Go version:"
    go version
    ;;
  "go-latest")
    echo "Installing latest Go..."
    install_package golang-go
    echo "Installed Go version:"
    go version
    ;;
  "python-3.10-pip")
    echo "TODO: Install Python 3.10 and pip..."
    ;;
  
  "none")
    echo "No additional runtime setup required."
    ;;
  *)
    echo "Nothing to install for: $RUNTIME"
    exit 0
    ;;
esac

echo "Runtime setup complete." 