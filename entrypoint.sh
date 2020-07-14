#!/bin/bash

set -euo pipefail

# Config file for markdownlint
export CONFIG_FILE=${INPUT_CONFIG_FILE:-}

# Debug variable - enable by setting non-empty value
export DEBUG=${INPUT_DEBUG:-}

# Exclude files or directoryes which should not be linted
export EXCLUDE=${INPUT_EXCLUDE:-}

# Command line parameters for fd
export FD_CMD_PARAMS="${INPUT_FD_CMD_PARAMS:- --extension md --type f --exec-batch }"

# Command line parameters for fd
export MARKDOWNLINT_CMD_PARAMS="${INPUT_MARKDOWNLINT_CMD_PARAMS:-}"

# Set files or paths variable containing markdown files
export PATHS=${INPUT_PATHS:-}


function print_error() {
  echo -e "\e[31m*** ERROR: ${1}\e[m"
}

function print_info() {
  echo -e "\e[36m*** INFO: ${1}\e[m"
}


function error_trap() {
  print_error "[$(date +'%F %T')] Something went wrong - see the errors above..."
}

################
# Main
################

trap error_trap ERR

[ -n "${DEBUG}" ] && set -x

if [ -n "${PATHS}" ]; then
  for PATH in ${PATHS}; do
    FD_CMD_PARAMS+=(--search-path "${PATH}")
  done
fi

if [ -n "${EXCLUDE}" ]; then
  for EXCLUDED in ${EXCLUDE}; do
    FD_CMD_PARAMS+=(--exclude "${EXCLUDED}")
  done
fi

if [ -n "${CONFIG_FILE}" ]; then
  MARKDOWNLINT_CMD_PARAMS+=(--config "${CONFIG_FILE}")
fi

print_info "[$(date +'%F %T')] Start checking: \"${URL}\""
print_info "Running: fd ${FD_CMD_PARAMS[*]}"

IFS=$'\n'

for FILE in fd "${FD_CMD_PARAMS[@]}"; do
  print_info "*** $FILE"
  print_info "Running: markdownlint-cli ${MARKDOWNLINT_CMD_PARAMS[*]}"
  markdownlint-cli "${MARKDOWNLINT_CMD_PARAMS[@]}"
done

print_info "[$(date +'%F %T')] Checks completed..."
