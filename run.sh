#!/bin/bash
# run.sh — Launch the Claude Code + Swift dev container
#
# Usage:
#   ./run.sh                    # interactive zsh shell
#   ./run.sh -- bootstrap.sh    # run bootstrap then exit

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/shared"
ENV_ARGS=()
if [ -f "$SCRIPT_DIR/.env" ]; then
  ENV_ARGS+=(--env-file "$SCRIPT_DIR/.env")
fi

mkdir -p "$SHARED_DIR"

container system start

container run -it --rm \
  --ssh \
  "${ENV_ARGS[@]}" \
  --volume "$HOME/.claude:/home/dev/.claude" \
  --volume "$HOME/.claude.json:/home/dev/.claude.json" \
  --volume "$SHARED_DIR:/shared" \
  claude-dev:latest \
  "$@"
