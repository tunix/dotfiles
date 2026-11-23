#!/bin/sh
# .scripts/ui.sh — the one output format every recipe and script uses.
#
#   . "$repo_root/.scripts/ui.sh"
#   ui_init brew-sync
#   out=$(ui_capture brew bundle --file="$f")   # output -> the step's log
#   ui_ok "67 packages in 7 Brewfiles, all present"
#
# One line per step, status in a fixed left column, so a whole run reads top
# to bottom:
#
#   ok    brew-sync            67 packages in 7 Brewfiles, all present
#   upd   apply                14 files changed
#   skip  aws-session-manager  AWS CLI not installed
#   warn  theme-sync           toggle-color-preferences.sh missing; run `just apply`
#   fail  check                3 errors
#
#   ok    the target is already in place, nothing changed
#   upd   the step changed something
#   skip  the step does not apply on this machine
#   warn  something was off, the step continued
#   fail  the step failed (the recipe exits non-zero)
#
#   ui_note     an indented detail line under the current step; buffered and
#               printed with the status line, so a step that walks many items
#               reports once at the end
#   ui_detail   the same, printed right away (after the status line)
#   ui_run      run a command, keep its output in $DOTFILES_LOGS/<step>.log
#               (and in $ui_last_output) and report a failure
#   ui_capture  the same, with the output on stdout (use with `$(...)`) and a
#               failure left to the caller to interpret
#
# A command's log is printed when it fails, and live with
# DOTFILES_VERBOSE=1 (`just setup-verbose`). Every status line is appended to
# $DOTFILES_REPORT, tagged with DOTFILES_RUN (one id per just invocation,
# exported by the host file), so the tally .scripts/summary.sh prints at the
# end of setup counts exactly this run — a step run on its own never leaks
# into a later tally.
#
# Recipes that print a report rather than change state (status, path-show,
# extensions-list, dconf-vs-defaults) keep their own output.

DOTFILES_UI_NAME_WIDTH=${DOTFILES_UI_NAME_WIDTH:-19}
DOTFILES_CACHE=${DOTFILES_CACHE:-${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles}
DOTFILES_LOGS=${DOTFILES_LOGS:-$DOTFILES_CACHE/logs}
DOTFILES_REPORT=${DOTFILES_REPORT:-$DOTFILES_CACHE/status.tsv}
DOTFILES_RUN=${DOTFILES_RUN:-standalone}

ui_step=
ui_notes=

ui_dim=
ui_green=
ui_yellow=
ui_red=
ui_off=
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-}" != dumb ]; then
    ui_dim=$(printf '\033[2m')
    ui_green=$(printf '\033[32m')
    ui_yellow=$(printf '\033[33m')
    ui_red=$(printf '\033[31m')
    ui_off=$(printf '\033[0m')
fi

# ui_init <step>: start a step. The first step of a run empties the report;
# the step's log starts empty too.
ui_init() {
    ui_step=$1
    ui_notes=
    mkdir -p "$DOTFILES_LOGS" "$(dirname "$DOTFILES_REPORT")" 2>/dev/null || true
    : >"$DOTFILES_LOGS/$ui_step.log"
    if [ -f "$DOTFILES_REPORT" ]; then
        if [ "$(head -n 1 "$DOTFILES_REPORT" | cut -f1)" != "$DOTFILES_RUN" ]; then
            : >"$DOTFILES_REPORT"
        fi
    fi
}

ui_color() {
    case $1 in
        upd) printf '%s' "$ui_green" ;;
        warn) printf '%s' "$ui_yellow" ;;
        fail) printf '%s' "$ui_red" ;;
        *) printf '%s' "$ui_dim" ;;
    esac
}

ui_record() {
    mkdir -p "$(dirname "$DOTFILES_REPORT")" 2>/dev/null || return 0
    printf '%s\t%s\t%s\t%s\n' "$DOTFILES_RUN" "$1" "$ui_step" "$2" >>"$DOTFILES_REPORT" 2>/dev/null || true
}

# ui_status <ok|upd|skip|warn|fail> [message]: print and record the step.
ui_status() {
    ui_state=$1
    shift
    ui_msg=$*
    if [ -n "$ui_msg" ]; then
        printf '  %s%-4s%s %-*s %s\n' \
            "$(ui_color "$ui_state")" "$ui_state" "$ui_off" \
            "$DOTFILES_UI_NAME_WIDTH" "$ui_step" "$ui_msg"
    else
        printf '  %s%-4s%s %s\n' "$(ui_color "$ui_state")" "$ui_state" "$ui_off" "$ui_step"
    fi
    if [ -n "$ui_notes" ]; then
        printf '%s' "$ui_notes" | while IFS= read -r ui_note_line; do
            printf '  %*s%s%s%s\n' "$((DOTFILES_UI_NAME_WIDTH + 5))" '' \
                "$ui_dim" "$ui_note_line" "$ui_off"
        done
    fi
    ui_notes=
    ui_record "$ui_state" "$ui_msg"
}

ui_ok() { ui_status ok "$@"; }
ui_upd() { ui_status upd "$@"; }
ui_skip() { ui_status skip "$@"; }
ui_warn() { ui_status warn "$@"; }
ui_fail() { ui_status fail "$@"; }

# ui_note <text>: an indented detail line, buffered and printed with the
# step's status line (call it while working out what the step did).
ui_note() {
    ui_notes="${ui_notes}$1
"
}

# ui_detail <text>: an indented detail line printed right away — for the block
# of details that belongs under a status line already printed (apply's list of
# changed files).
ui_detail() {
    printf '  %*s%s%s%s\n' "$((DOTFILES_UI_NAME_WIDTH + 5))" '' "$ui_dim" "$1" "$ui_off"
}

# ui_plural <count> <singular> <plural>: "1 file", "3 files".
ui_plural() {
    if [ "$1" = 1 ]; then
        printf '%s %s' "$1" "$2"
    else
        printf '%s %s' "$1" "$3"
    fi
}

# ui_log <tmpfile>: append a command's output to the step's log, echoing it
# when DOTFILES_VERBOSE=1.
ui_log() {
    cat "$1" >>"$DOTFILES_LOGS/$ui_step.log"
    if [ "${DOTFILES_VERBOSE:-0}" = 1 ]; then
        sed 's/^/  /' "$1" >&2
    fi
}

# ui_run <command...>: run it, output into the step's log and into
# $ui_last_output. On failure the log is printed and the step is recorded as
# failed (the recipe then exits).
ui_run() {
    ui_out=$(mktemp)
    ui_rc=0
    # `|| ui_rc=$?` and not a bare call: the calling recipe runs under `set -e`
    # and would exit before the failure could be reported
    "$@" >"$ui_out" 2>&1 || ui_rc=$?
    ui_log "$ui_out"
    ui_last_output=$(cat "$ui_out")
    rm -f "$ui_out"
    if [ "$ui_rc" != 0 ]; then
        ui_fail "$* failed (exit $ui_rc)"
        ui_note "log: $DOTFILES_LOGS/$ui_step.log"
        printf '  %*s%s%s%s\n' "$((DOTFILES_UI_NAME_WIDTH + 5))" '' "$ui_dim" \
            "$DOTFILES_LOGS/$ui_step.log" "$ui_off"
        sed 's/^/      /' "$DOTFILES_LOGS/$ui_step.log" >&2
    fi
    return $ui_rc
}

# ui_capture <command...>: like ui_run, but the output goes to stdout, so the
# caller can read it: out=$(ui_capture dconf dump /). A failure is NOT
# reported — the caller decides what it means (see `extensions`, which warns
# and carries on).
ui_capture() {
    ui_out=$(mktemp)
    ui_rc=0
    "$@" >"$ui_out" 2>&1 || ui_rc=$?
    ui_log "$ui_out"
    cat "$ui_out"
    rm -f "$ui_out"
    return $ui_rc
}
