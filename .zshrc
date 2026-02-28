# Prompt: claude-dev:/workspace/repo (branch*)#
autoload -Uz add-zsh-hook vcs_info
zstyle ':vcs_info:git:*' formats ' (%F{yellow}%b%f%m)'
zstyle ':vcs_info:git:*' actionformats ' (%F{yellow}%b%f|%F{red}%a%f%m)'
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{green}+%f'
zstyle ':vcs_info:git:*' unstagedstr '%F{red}*%f'
zstyle ':vcs_info:*' enable git

# Append dirty indicators after branch
+vi-git-dirty() {
    local dirty=""
    [[ -n "${hook_com[staged]}" ]] && dirty+="${hook_com[staged]}"
    [[ -n "${hook_com[unstaged]}" ]] && dirty+="${hook_com[unstaged]}"
    hook_com[misc]+="$dirty"
}
zstyle ':vcs_info:git*+set-message:*' hooks git-dirty

precmd() { vcs_info }
setopt prompt_subst
PROMPT='%F{208}claude-dev%f:%F{yellow}%~%f${vcs_info_msg_0_}%F{208}#%f '

# Check if bootstrap has run (any git repos in /workspace)
if ! ls -d /workspace/*/.git &>/dev/null; then
    echo ""
    echo "Welcome to the Claude Code + Swift dev container!"
    echo ""
    if [ -f /shared/repos.txt ]; then
        echo "Run 'bootstrap.sh' to clone your repos into /workspace."
    else
        echo "To get started:"
        echo "  1. Create shared/repos.txt on the host with your git URLs (one per line)"
        echo "  2. Run 'bootstrap.sh'"
    fi
    echo ""
fi
