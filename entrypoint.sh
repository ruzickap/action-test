#!/bin/bash

set -euo pipefail

# Command line parameters for muffet
export CMD_PARAMS="${INPUT_CMD_PARAMS:---buffer-size=8192 --concurrency=10}"
# Set path variable containing web pages
export PAGES_PATH=${INPUT_PAGES_PATH:-}
# URL to scan / check
export URL=${INPUT_URL:?}
# Domain where the web pages will be hosted (test.example.com), it will be stored in /etc/hosts
PAGES_DOMAIN=$( echo "${URL}" | awk -F[/:] '{print $4}' )
export PAGES_DOMAIN
# URI used by caddy to serve locally stored web pages (https://test.example.com)
PAGES_URI=$( echo "${URL}" | cut -d / -f 1,2,3 )
export PAGES_URI
# Max number of seconds which URL checker can be running
export RUN_TIMEOUT="${INPUT_RUN_TIMEOUT:-300}"
# Debug variable - enable by setting non-empty value
export DEBUG=${INPUT_DEBUG:-}

function print_error() {
  echo -e "\e[31m*** ERROR: ${1}\e[m"
}

function print_info() {
  echo -e "\e[36m*** INFO: ${1}\e[m"
}

# Remove all added files or changed /etc/hosts entry
function cleanup() {
  if [ -n "${PAGES_PATH}" ]; then
    # Manipulation with /etc/hosts using 'sed -i' doesn't work in containers
    if ! grep -q docker /proc/1/cgroup ; then
      sudo sed -i "/127.0.0.1 ${PAGES_DOMAIN}  # Created for broken-link-checker/d" /etc/hosts
    fi
    [ -s "${CADDY_PIDFILE}" ] && sudo kill "$(cat "${CADDY_PIDFILE}")"
    [ -f "${CADDYFILE}" ] && rm "${CADDYFILE}"
  fi
}

function error_trap() {
  cleanup
  print_error "*** Something went wrong - see the errors above..."
}

################
# Main
################

trap error_trap ERR

[ -n "${DEBUG}" ] && set -x

# Install muffet if needed
if ! hash muffet &> /dev/null ; then
  MUFFET_URL=$(wget --quiet https://api.github.com/repos/raviqqe/muffet/releases/latest -O - | grep "browser_download_url.*muffet_.*_Linux_x86_64.tar.gz" | cut -d \" -f 4)
  wget --quiet "${MUFFET_URL}" -O - | sudo tar xzf - -C /usr/local/bin/ muffet
fi

# Install caddy if needed
if ! hash caddy &> /dev/null && [ -n "${PAGES_PATH}" ] ; then
  wget -qO- https://getcaddy.com | sudo bash -s personal > /dev/null
fi

# Use muffet in case of simple URL check
if [ -z "${PAGES_PATH}" ] ; then
  print_info "Using URL - ${URL}"
  # shellcheck disable=SC2086
  timeout "${RUN_TIMEOUT}" muffet ${CMD_PARAMS} "${URL}"
else
  print_info "Using path \"${PAGES_PATH}\" as domain \"${PAGES_DOMAIN}\" with URI \"${PAGES_URI}\""
  # Add domain into /etc/hosts
  if ! grep -q "${PAGES_DOMAIN}" /etc/hosts ; then
    sudo bash -c "echo \"127.0.0.1 ${PAGES_DOMAIN}  # Created in /etc/hosts for broken-link-checker\" >> /etc/hosts"
  fi
  CADDYFILE=$( mktemp /tmp/Caddyfile.XXXXXX )
  CADDY_PIDFILE=$( mktemp -u /tmp/Caddy_pidfile.XXXXXX )
  # Create caddy configuration to run web server using the domain set in /etc/hosts (loop)
  cat > "${CADDYFILE}" << EOF
  ${PAGES_URI}
  root ${PAGES_PATH}
  tls self_signed
EOF
  # Run caddy web server on the background
  sudo caddy -conf "${CADDYFILE}" -pidfile "${CADDY_PIDFILE}" -quiet &
  sleep 1
  # shellcheck disable=SC2086
  timeout "${RUN_TIMEOUT}" muffet ${CMD_PARAMS} "${URL}"
  cleanup
fi

print_info "Checks completed..."
