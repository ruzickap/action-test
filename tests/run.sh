#!/bin/bash -eux

export DEBUG="true"

# Test entrypoint.sh script

## Check differnet URLs types
export MUFFET_CMD_PARAMS="--one-page-only --buffer-size=8192 --concurrency=10 --verbose"

export URL="https://google.com"
../entrypoint.sh

export URL="https://google.com:443"
../entrypoint.sh

export URL="https://google.com:443/search"
../entrypoint.sh

## Test locally stored web pages (PAGES_PATH)
export MUFFET_CMD_PARAMS="--skip-tls-verification --verbose"

export PAGES_PATH="${PWD}"
export URL="http://my-testing-domain.com/index2.html"
../entrypoint.sh

export PAGES_PATH="${PWD}"
export URL="https://my-testing-domain.com"
../entrypoint.sh

## Test docker image

docker build .. -t broken-link-checker-test-img

export MUFFET_CMD_PARAMS="--one-page-only --buffer-size=8192 --concurrency=10 --verbose"
export URL="https://google.com"
docker run --rm -e DEBUG -e URL -e MUFFET_CMD_PARAMS broken-link-checker-test-img

export MUFFET_CMD_PARAMS="--skip-tls-verification --verbose"
export PAGES_PATH="${PWD}"
export URL="http://my-testing-domain.com/index2.html"
docker run --rm -e DEBUG -e URL -e MUFFET_CMD_PARAMS -e PAGES_PATH -v "$PAGES_PATH:$PAGES_PATH" broken-link-checker-test-img
