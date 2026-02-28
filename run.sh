#!/bin/bash
# run.sh — Launch the Claude Code + Swift dev container
#
# Usage:
#   ./run.sh                # start or attach to persistent container
#   ./run.sh --fresh        # start a new ephemeral container (removed on exit)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SHARED_DIR="$SCRIPT_DIR/shared"
CONTAINER_NAME="claude-dev"

FRESH=false
PASSTHROUGH_ARGS=()
for arg in "$@"; do
  case "$arg" in
    --fresh) FRESH=true ;;
    *) PASSTHROUGH_ARGS+=("$arg") ;;
  esac
done

ENV_ARGS=()
if [ -f "$SCRIPT_DIR/.env" ]; then
  ENV_ARGS+=(--env-file "$SCRIPT_DIR/.env")
fi

mkdir -p "$SHARED_DIR"

container system start

if [ "$FRESH" = true ]; then
  container run -it --rm \
    --ssh \
    "${ENV_ARGS[@]}" \
    --volume "$HOME/.claude:/home/dev/.claude" \
    --volume "$HOME/.claude.json:/home/dev/.claude.json" \
    --volume "$SHARED_DIR:/shared" \
    claude-dev:latest \
    "${PASSTHROUGH_ARGS[@]}"
else
  # Check if the named container is already running
  if container list 2>/dev/null | grep -q "$CONTAINER_NAME"; then
    echo "Attaching to running container '$CONTAINER_NAME'..."
    container exec -it "$CONTAINER_NAME" zsh "${PASSTHROUGH_ARGS[@]}"
  else
    container run -it \
      --name "$CONTAINER_NAME" \
      --ssh \
      "${ENV_ARGS[@]}" \
      --volume "$HOME/.claude:/home/dev/.claude" \
      --volume "$HOME/.claude.json:/home/dev/.claude.json" \
      --volume "$SHARED_DIR:/shared" \
      claude-dev:latest \
      "${PASSTHROUGH_ARGS[@]}"
  fi
fi
