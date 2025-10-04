#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# ml-menu.sh
# -----------------------------------------------------------------------------
# Minimal UI layer for the "ml-debug" ecosystem. This wrapper currently uses
# rofi as the only backend to display interactive menus.
#
# Enhancements:
#   - Supports tab-separated input (label\tdescription). The user sees both
#     columns in rofi, but only the label is returned.
#   - Default prompt for second-level menu simplified: "[module] :" instead of
#     "[module]: tool:"
#
# Dependencies:
#   - bash (>= 4)
#   - rofi
#
# This file is intended to be sourced. It exposes a single function:
#   ml_menu_select "<prompt>" < <items>
# which prints the chosen label to stdout and returns 0; if the user cancels,
# it returns non-zero and prints nothing.
# -----------------------------------------------------------------------------
set -o errexit -o pipefail -o nounset

: "${ML_ROFI_LINES:=15}"
: "${ML_ROFI_PROMPT_SUFFIX:=}"  # optional suffix appended to prompt
: "${ML_ROFI_ARGS:=}"           # extra user-provided rofi args

_ml_rofi_dmenu() {
  local prompt="$1"
  rofi -dmenu -i -l "${ML_ROFI_LINES}" -p "${prompt}${ML_ROFI_PROMPT_SUFFIX}" ${ML_ROFI_ARGS}
}

# Reads a list from stdin; each line can be either:
#   label
# or label\tdescription
# The display will show both, separated by some spacing, but only the label
# is returned when the user selects an entry.
ml_menu_select() {
  local prompt="$1"; shift || true
  local input selection label
  # Pre-format lines for better readability in rofi: align columns if possible.
  input=$(awk -F"\t" '{printf "%-20s %s\n", $1, $2}' 2>/dev/null || cat)
  if ! selection="$(printf '%s\n' "$input" | _ml_rofi_dmenu "$prompt")"; then
    return 1
  fi
  [[ -z "${selection}" ]] && return 1
  # Extract the label (first column) and trim whitespace.
  label="$(awk '{print $1}' <<<"${selection}")"
  printf "%s\n" "${label}"
}
