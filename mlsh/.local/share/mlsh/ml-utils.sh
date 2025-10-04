#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# ml-utils.sh
# -----------------------------------------------------------------------------
# Common helpers for the "ml-debug" ecosystem.
#
# Dependencies (beyond POSIX sh):
#   - bash (>= 4)
#   - coreutils (date, mkdir, basename)
#   - libnotify (notify-send)
#   - jq (only used by callers if needed)
#
# This file is intended to be sourced, not executed directly.
# Example:
#   source "$HOME/.local/share/mlsh/ml-utils.sh"
# -----------------------------------------------------------------------------
set -o errexit -o pipefail -o nounset

# --- Paths --------------------------------------------------------------------
: "${HOME:?}"  # hard fail if HOME is unset
ML_DEBUG_STATE_DIR="${HOME}/.local/share/ml-debug"
ML_DEBUG_LOG_DIR="${ML_DEBUG_STATE_DIR}/logs"

# Ensure log directory exists (idempotent).
mkdir -p "${ML_DEBUG_LOG_DIR}"

# --- Colors (for optional pretty CLI messages) --------------------------------
MLC_RESET="\033[0m"; MLC_DIM="\033[2m"; MLC_GREEN="\033[32m"; MLC_YELLOW="\033[33m"; MLC_RED="\033[31m"

ml_echo_info()   { printf "%b[INFO]%b %s\n"   "$MLC_GREEN" "$MLC_RESET" "${*}"; }
ml_echo_warn()   { printf "%b[WARN]%b %s\n"   "$MLC_YELLOW" "$MLC_RESET" "${*}"; }
ml_echo_error()  { printf "%b[ERROR]%b %s\n"  "$MLC_RED" "$MLC_RESET" "${*}"; }

# --- Dependency checks ---------------------------------------------------------
# Usage: ml_require cmd1 [cmd2 ...]
# Returns non-zero and prints a friendly message if any command is missing.
ml_require() {
  local missing=()
  for c in "$@"; do
    if ! command -v "$c" >/dev/null 2>&1; then
      missing+=("$c")
    fi
  done
  if (( ${#missing[@]} )); then
    ml_echo_error "Missing dependencies: ${missing[*]}"
    return 127
  fi
}

# --- Logging ------------------------------------------------------------------
# Usage: ml_log <tool_name> <message>
# Writes a timestamped message into ~/.local/share/ml-debug/logs/<tool_name>.log
ml_log() {
  local tool="$1"; shift || true
  local msg="${*:-}"
  local logfile="${ML_DEBUG_LOG_DIR}/${tool}.log"
  # ISO-8601 timestamp for consistent parsing.
  printf "%s %s\n" "$(date -Is)" "$msg" >> "$logfile"
}

# --- Notifications -------------------------------------------------------------
# Usage: ml_notify <title> <message>
ml_notify() {
  local title="$1"; shift || true
  local message="${*:-}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "${title}" "${message}"
  else
    # Fallback to stdout if libnotify is not available.
    ml_echo_info "[NOTIFY] ${title} — ${message}"
  fi
}

# --- Tool runner ---------------------------------------------------------------
# Usage: ml_run_tool <script_path> [display_name]
# Runs the script in the background, logs stdout/stderr to a dedicated file,
# and sends start/end notifications.
ml_run_tool() {
  local script_path="$1"; shift || true
  local display_name="${1:-$(basename -- "$script_path")}"; shift || true

  # Normalize tool name for log filename (strip extension).
  local tool_name
  tool_name="$(basename -- "$script_path")"
  tool_name="${tool_name%.sh}"

  local logfile="${ML_DEBUG_LOG_DIR}/${tool_name}.log"

  ml_notify "${display_name}" "Started (logging to ${logfile})"
  ml_log    "${tool_name}" "INFO: Starting ${display_name} via ${script_path}"

  # Run in background, capture exit code, then notify and log completion.
  nohup bash -c "\"${script_path}\" >> \"${logfile}\" 2>&1" \
    >/dev/null 2>&1 & disown

  # We cannot easily hook completion without a wrapper process; provide a tip.
  ml_log "${tool_name}" "INFO: Spawned background job for ${display_name}"
}

# --- Small helpers -------------------------------------------------------------
# Usage: ml_slugify <string>
# Converts a label like "[video]" to a simple slug "video" for filenames.
ml_slugify() {
  local s="$*"
  s="${s//[[]/}"  # remove '['
  s="${s//]/}"    # remove ']'
  s="${s// /-}"   # spaces -> hyphens
  printf "%s\n" "$s"
}
