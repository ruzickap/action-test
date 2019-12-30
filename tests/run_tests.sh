#!/bin/bash -eux

export INPUT_DEBUG="true"

# Test entrypoint.sh script

## Check differnet URLs types
export INPUT_CMD_PARAMS="--one-page-only --buffer-size=8192 --concurrency=10 --verbose"

export INPUT_URL="https://google.com"
../entrypoint.sh

export INPUT_URL="https://google.com:443"
../entrypoint.sh

export INPUT_URL="https://google.com:443/search"
../entrypoint.sh

## Test locally stored web pages (PAGES_PATH)
export INPUT_CMD_PARAMS="--skip-tls-verification --verbose"

export INPUT_PAGES_PATH="${PWD}"
export INPUT_URL="http://my-testing-domain.com/index2.html"
../entrypoint.sh

export INPUT_PAGES_PATH="${PWD}"
export INPUT_URL="https://my-testing-domain.com"
../entrypoint.sh

## Test docker image

docker build .. -t broken-link-checker-test-img

export INPUT_CMD_PARAMS="--one-page-only --buffer-size=8192 --concurrency=10 --verbose"
export INPUT_URL="https://google.com"
docker run --rm -t -e INPUT_DEBUG -e INPUT_URL -e INPUT_CMD_PARAMS broken-link-checker-test-img

export INPUT_CMD_PARAMS="--skip-tls-verification --verbose"
export INPUT_PAGES_PATH="${PWD}"
export INPUT_URL="https://my-testing-domain.com"
docker run --rm -t -e INPUT_DEBUG -e INPUT_URL -e INPUT_CMD_PARAMS -e INPUT_PAGES_PATH -v "$INPUT_PAGES_PATH:$INPUT_PAGES_PATH" broken-link-checker-test-img

export INPUT_CMD_PARAMS="--verbose"
export INPUT_PAGES_PATH="${PWD}"
export INPUT_URL="http://my-testing-domain.com/index2.html"
docker run --rm -t -e INPUT_DEBUG -e INPUT_URL -e INPUT_CMD_PARAMS -e INPUT_PAGES_PATH -v "$INPUT_PAGES_PATH:$INPUT_PAGES_PATH" broken-link-checker-test-img
