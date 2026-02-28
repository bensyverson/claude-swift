#!/bin/sh
# build.sh — Build the Claude Code + Swift dev container image
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
container system start
container build -t claude-dev "$SCRIPT_DIR"
