# Claude Code + Swift Development Container
# Designed for Apple's `container` CLI
#
# Build:  container build -t claude-dev .
# Run:    ./run.sh

FROM docker.io/swift:6.2

ARG CLAUDE_CODE_VERSION=latest

# System tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    zsh \
    bash \
    curl \
    jq \
    nano \
    vim \
    less \
    openssh-client \
    ca-certificates \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       -o /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20 (required for Claude Code)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# Claude Code
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# SwiftFormat (download pre-built binary)
RUN SWIFTFORMAT_VERSION=$(curl -fsSL https://api.github.com/repos/nicklockwood/SwiftFormat/releases/latest | jq -r '.tag_name') \
    && curl -fsSL "https://github.com/nicklockwood/SwiftFormat/releases/download/${SWIFTFORMAT_VERSION}/swiftformat_linux.zip" \
       -o /tmp/swiftformat.zip \
    && apt-get update && apt-get install -y --no-install-recommends unzip \
    && unzip /tmp/swiftformat.zip -d /usr/local/bin/ \
    && mv /usr/local/bin/swiftformat_linux /usr/local/bin/swiftformat \
    && chmod +x /usr/local/bin/swiftformat \
    && rm /tmp/swiftformat.zip \
    && apt-get purge -y unzip && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*


# Non-root user — reuse existing uid 1000 if present, otherwise create
RUN if id -nu 1000 >/dev/null 2>&1; then \
        existing=$(id -nu 1000) \
        && usermod -l dev -d /home/dev -m -s /bin/zsh "$existing" \
        && groupmod -n dev "$(id -gn 1000)" ; \
    else \
        useradd -m -s /bin/zsh -u 1000 dev ; \
    fi
# Workspace (create before switching to non-root)
RUN mkdir -p /workspace && chown dev:dev /workspace

USER dev
COPY --chown=dev:dev .zshrc /home/dev/.zshrc
WORKDIR /workspace

# Copy bootstrap script
COPY --chown=dev:dev bootstrap.sh /usr/local/bin/bootstrap.sh

ENTRYPOINT ["zsh"]
