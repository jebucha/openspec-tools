#!/usr/bin/env bash
set -euo pipefail

TARGET="$HOME/.openspec-tools"

mkdir -p "$TARGET"
cp -r * .gitignore "$TARGET/"

echo "Installed openspec-tools to $TARGET"
