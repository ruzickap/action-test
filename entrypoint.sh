#!/bin/bash

set -euo pipefail

export MUFFET_CMD_PARAMS="${MUFFET_CMD_PARAMS:-}"
export PAGES_PATH=${PAGES_PATH:-}
export URL=${URL:?}
PAGES_DOMAIN=$( echo "${URL}" | awk -F[/:] '{print $4}' )
export PAGES_DOMAIN
PAGES_URI=$( echo "${URL}" | cut -d / -f 1,2,3 )
export PAGES_URI
export RUN_TIMEOUT="${RUN_TIMEOUT:-300}"
export BUFFER_SIZE="8192"
export CONCURRENCY="10"

function print_error() {
  echo -e "\e[31m*** ERROR: ${1}\e[m"
}

function print_info() {
  echo -e "\e[36m*** INFO: ${1}\e[m"
}


if command -v muffet; then
  MUFFET_URL=$(wget --quiet https://api.github.com/repos/raviqqe/muffet/releases/latest -O - | grep "browser_download_url.*muffet_.*_Linux_x86_64.tar.gz" | cut -d \" -f 4)
  wget --quiet "${MUFFET_URL}" -O - | tar xvzf - -C /usr/local/bin/ muffet
fi

if command -v caddy; then
  wget -qO- https://getcaddy.com | bash -s personal
fi

if [ -n "${URL}" ]; then
  print_info "Using URL - ${URL}"
  # shellcheck disable=SC2086
  timeout "${RUN_TIMEOUT}" muffet ${MUFFET_CMD_PARAMS} "${URL}"
elif [ -n "${PAGES_PATH}" ]; then
  print_info "Using path \"${PAGES_PATH}\" as domain \"${PAGES_DOMAIN}\" with uri \"${PAGES_URI}\""
  echo "127.0.0.1 ${PAGES_DOMAIN}" | sudo tee -a /etc/hosts
  CADDYFILE=$( mktemp /tmp/Caddyfile.XXXXXX )
  cat > "${CADDYFILE}" << EOF
  ${PAGES_URI}
  root ${PATH}
  tls self_signed
EOF
  sudo caddy -conf "${CADDYFILE}" -quiet &
  # shellcheck disable=SC2086
  timeout "${RUN_TIMEOUT}" muffet ${MUFFET_CMD_PARAMS} "${URL}"
else
    print_error "Missing URL variable"
    exit 1
fi
