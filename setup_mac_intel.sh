#!/bin/bash
# This script sets up a basic L1 development environment on an Intel-based Mac.

set -e

# Update Homebrew and installed packages
echo "Updating Homebrew..."
brew update && brew upgrade

# Install Rust toolchain
if ! command -v cargo >/dev/null 2>&1; then
  echo "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
fi

# Build tools & libraries
echo "Installing build tools and libraries..."
brew install cmake pkg-config openssl protobuf git clang

# Check tool versions
echo "Tool versions:"
clang --version
cmake --version
cargo --version

# Create project directory
mkdir -p compliance-asset-registry-chain && cd compliance-asset-registry-chain

echo "Initializing git repository..."
if [ ! -d .git ]; then
  git init
fi

# Create Rust workspace modules if they don't already exist
for crate in consensus_engine registry_vm node network_stack; do
  if [ ! -e "$crate" ]; then
    if [ "$crate" = "node" ]; then
      cargo new --bin "$crate"
    else
      cargo new --lib "$crate"
    fi
  fi
done

# Build the workspace
cargo build --workspace

# Install and run clippy
rustup component add clippy
cargo clippy --workspace --all-targets --all-features

# Initial commit
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Initial compliance asset registry L1 workspace"
fi

echo "Setup complete. Your Mac is ready for L1 blockchain development."
