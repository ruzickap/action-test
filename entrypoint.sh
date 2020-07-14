#!/bin/bash

set -euo pipefail

# Config file for markdownlint
export CONFIG_FILE=${INPUT_CONFIG_FILE:-}

# Debug variable - enable by setting non-empty value
export DEBUG=${INPUT_DEBUG:-}

# Exclude files or directoryes which should not be linted
export EXCLUDE=${INPUT_EXCLUDE:-}

# Command line parameters for fd
export FD_CMD_PARAMS="${INPUT_FD_CMD_PARAMS:- -0 --extension md --type f }"

# Command line parameters for fd
export MARKDOWNLINT_CMD_PARAMS="${INPUT_MARKDOWNLINT_CMD_PARAMS:-}"

# Set files or paths variable containing markdown files
export SEARCH_PATHS=${INPUT_SEARCH_PATHS:-}


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

echo $PATH
ls -la /usr/bin/fd /bin/date

[ -n "${DEBUG}" ] && set -x

if [ -n "${SEARCH_PATHS}" ]; then
  for SEARCH_PATH in ${SEARCH_PATHS}; do
    FD_CMD_PARAMS+=(--search-path "${SEARCH_PATH}")
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

print_info "[$(date +'%F %T')] Start checking..."
print_info "Running: fd ${FD_CMD_PARAMS[*]}"

IFS=$'\0'

for FILE in $(fd "${FD_CMD_PARAMS[@]}"); do
  print_info "*** $FILE"
  print_info "Running: markdownlint ${MARKDOWNLINT_CMD_PARAMS[*]}"
  markdownlint "${MARKDOWNLINT_CMD_PARAMS[@]}"
done

print_info "[$(date +'%F %T')] Checks completed..."
