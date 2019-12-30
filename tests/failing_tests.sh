#!/bin/bash -ux

export INPUT_DEBUG="true"

echo -e "\n\n!!! Test when RUN_TIMEOUT is too tight"

export INPUT_CMD_PARAMS="--one-page-only --concurrency=1 --verbose"
export INPUT_RUN_TIMEOUT="1"
export INPUT_URL="https://google.com"
../entrypoint.sh
unset INPUT_RUN_TIMEOUT

echo -e "\n\n!!! Test nonexisting directory specified as PAGES_PATH"

export INPUT_PAGES_PATH="/non-existing-dir"
export INPUT_URL="https://google.com"
../entrypoint.sh

echo -e "\n\n!!! Test broken links by accessing wrong non existing domain"

export INPUT_PAGES_PATH="$PWD"
export INPUT_URL="https://non-existing-domain.com"
../entrypoint.sh

echo -e "\n\n!!! Test broken links by accessing non existing links"

export INPUT_PAGES_PATH="$PWD"
export INPUT_URL="https://my-testing-domain.com/index2.html"
../entrypoint.sh
