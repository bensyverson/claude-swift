# Claude Code + Swift Dev Container

A sandboxed Linux dev container for running Claude Code with the Swift toolchain, designed for Apple's [`container`](https://github.com/apple/container) CLI. Run `claude --dangerously-skip-permissions` without risking the host machine.

## What's in the box

- **Swift 6.2** — full toolchain (compiler, SPM, LLDB)
- **Node.js 20** — required runtime for Claude Code
- **Claude Code** — `@anthropic-ai/claude-code`, installed globally
- **SwiftFormat** — for linting Swift projects
- **GitHub CLI** (`gh`) — for PR workflows
- **Dev tools** — git, zsh, curl, jq, nano, vim, openssh-client

## Quick start

0. **Install `container`** by [downloading the latest release](https://github.com/apple/container/releases). (Requires macOS 26)

1. **Add your repos** to `shared/repos.txt` (one git URL per line — SSH or HTTPS):

   ```
   cp shared/repos.example.txt shared/repos.txt
   ```

   Then edit `shared/repos.txt` with your repo URLs.

2. **Build the image:**

   ```bash
   ./build.sh
   ```

3. **Launch the container:**

   ```bash
   ./run.sh
   ```

4. **Clone your repos** (inside the container):

   ```bash
   bootstrap.sh
   ```

5. **Start working:**

   ```bash
   cd /workspace/your-project
   claude --dangerously-skip-permissions
   ```

## SSH keys

The container uses SSH agent forwarding via `container run --ssh`. Your private keys **never exist** inside the container — the host's `SSH_AUTH_SOCK` is forwarded and git operations use it transparently.

No need to copy or mount `~/.ssh`. Just make sure your SSH agent is running on the host (`ssh-add -l` to verify).

## Claude Code auth

Your existing Claude Code session is shared from the host via volume mounts:

- `~/.claude` — session data, project memories, settings
- `~/.claude.json` — auth tokens

This means you don't need to re-authenticate inside the container.

## Environment variables

Create a `.env` file in the repo root with any environment variables you need (e.g. API keys). It's automatically passed into the container and gitignored.

## Shared folder

The `shared/` directory is mounted at `/shared` inside the container. Use it to swap files between host and container. The container cannot access anything outside this directory.

## Usage patterns

**Mount additional volumes** — pass extra args through `run.sh`:

```bash
./run.sh --volume /path/to/data:/data
```

**Run a one-off command:**

```bash
./run.sh -- -c "swift --version"
```

**Build with a specific Claude Code version:**

```bash
container build -t claude-dev --build-arg CLAUDE_CODE_VERSION=1.0.0 .
```
