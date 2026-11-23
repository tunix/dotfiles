# --no-masking is required: without it op run pipes stdout/stderr
# (for secret masking) and opencode's TUI renders broken/blank
if status is-interactive
    alias oc "op run --no-masking --env-file=$HOME/.config/opencode/.env -- opencode"
    alias v "nvim"
end
