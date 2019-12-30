# GitHub Actions for checking broken links ✔

<!-- (https://github.com/marketplace/actions/action-test)  -->
[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Broken%20Link%20Checker-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/ruzickap/action-test/)
[![license](https://img.shields.io/github/license/ruzickap/action-test.svg)](https://github.com/ruzickap/action-test/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/ruzickap/action-test.svg)](https://github.com/ruzickap/action-test/releases/latest)
[![GitHub release date](https://img.shields.io/github/release-date/ruzickap/action-test.svg)](https://github.com/ruzickap/action-test/releases)
![GitHub Actions status](https://github.com/ruzickap/action-test/workflows/docker-image/badge.svg)
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/peru/action-test.svg)](https://hub.docker.com/r/peru/action-test)

This is a GitHub Action to check broken link in your static files or web pages.
The [muffet](https://github.com/raviqqe/muffet) is used for checking task.

See the basic GitHub Action example to run periodic checks (weekly)
against [google.com](https://google.com):

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'

name: Check markdown links
jobs:
  broken-link-checker:
    name: Check broken links
    runs-on: ubuntu-18.04
    steps:
    - name: Check
      uses: peru/action-test@v1
      with:
        url: https://www.google.com
        cmd_params: "--one-page-only"  # Check just one page
```

This deploy action can be combined simply and freely with [Static Site Generators](https://www.staticgen.com/).
(Hugo, MkDocs, Gatsby, GitBook, mdBook, etc.). The following examples expects
to have the web page stored in `./build` directory. There is a [caddy](https://caddyserver.com/)
started during the tests which is using the hostname from the `URL` parameter
and serving the web page (see the details in [entrypoint.sh](./entrypoint.sh)).

```yaml
- name: Check
  uses: peru/action-test@v1
  with:
    url: https://www.example.com/test123
    pages_path: ./build/
    cmd_params: --buffer-size=8192 --concurrency=10 --skip-tls-verification --limit-redirections=5 --timeout=20  # specify all necessary muffet parameters
    run_timeout: 600  # maximum amount of time to run muffet (default is set to 300 seconds)
```

Do you want to skip the docker build step? OK, the script mode is available.

```yaml
- name: Check
  env:
    INPUT_URL: https://www.example.com/test123
    INPUT_PAGES_PATH: ./build/
    INPUT_CMD_PARAMS: "--buffer-size=8192 --concurrency=10 --skip-tls-verification"  # --skip-tls-verification is mandatory parameter when using https and "PAGES_PATH"
  run: |
    wget -qO- https://raw.githubusercontent.com/ruzickap/action-test/v1/entrypoint.sh | bash
```

## Running locally

It's possible to use the script locally. It will install [caddy](https://caddyserver.com/)
and [muffet](https://github.com/raviqqe/muffet) binaries if they
are not already installed on your system.

```bash
export INPUT_URL="https://google.com"
export INPUT_CMD_PARAMS="--ignore-fragments --one-page-only --concurrency=10 --verbose"
./entrypoint.sh
```

Output:

```text
*** INFO: Using URL - https://google.com
https://www.google.com/
        200     http://www.google.cz/history/optout?hl=cs
        200     http://www.google.cz/intl/cs/services/
        200     https://accounts.google.com/ServiceLogin?hl=cs&passive=true&continue=https://www.google.com/
        200     https://drive.google.com/?tab=wo
        200     https://mail.google.com/mail/?tab=wm
        200     https://maps.google.cz/maps?hl=cs&tab=wl
        200     https://news.google.cz/nwshp?hl=cs&tab=wn
        200     https://play.google.com/?hl=cs&tab=w8
        200     https://www.google.com/advanced_search?hl=cs&authuser=0
        200     https://www.google.com/images/branding/googlelogo/1x/googlelogo_white_background_color_272x92dp.png
        200     https://www.google.com/intl/cs/about.html
        200     https://www.google.com/intl/cs/ads/
        200     https://www.google.com/intl/cs/policies/privacy/
        200     https://www.google.com/intl/cs/policies/terms/
        200     https://www.google.com/language_tools?hl=cs&authuser=0
        200     https://www.google.com/preferences?hl=cs
        200     https://www.google.com/setprefdomain?prefdom=CZ&prev=https://www.google.cz/&sig=K_r4B5zcKfyJMcX_GbP9etD047mEA%3D
        200     https://www.google.com/textinputassistant/tia.png
        200     https://www.google.cz/imghp?hl=cs&tab=wi
        200     https://www.google.cz/intl/cs/about/products?tab=wh
        200     https://www.youtube.com/?gl=CZ&tab=w1
*** INFO: Checks completed...
```

You can also use the advantage of the container to run the checks locally
without installing anything (except the container image) to your system:

```bash
export INPUT_URL="https://google.com"
export INPUT_CMD_PARAMS="--ignore-fragments --one-page-only --concurrency=10 --verbose"
export INPUT_URL="https://google.com"
docker run --rm -t -e INPUT_URL -e INPUT_CMD_PARAMS peru/action-test
```

Another example when checking the the web page locally stored on your disk.
In this case I'm using the web page created in the `./tests/` directory:

```bash
export INPUT_PAGES_PATH="${PWD}/tests/"
export INPUT_URL="https://my-testing-domain.com"
export INPUT_CMD_PARAMS="--skip-tls-verification --verbose"
./entrypoint.sh
```

Output:

```text
*** INFO: Using path "/home/pruzicka/git/action-test/tests/" as domain "my-testing-domain.com" with URI "https://my-testing-domain.com"
https://my-testing-domain.com/
        200     https://my-testing-domain.com
        200     https://my-testing-domain.com/run_tests.sh
        200     https://my-testing-domain.com:443
        200     https://my-testing-domain.com:443/run_tests.sh
https://my-testing-domain.com:443/
        200     https://my-testing-domain.com
        200     https://my-testing-domain.com/run_tests.sh
        200     https://my-testing-domain.com:443
        200     https://my-testing-domain.com:443/run_tests.sh
*** INFO: Checks completed...
```

The same example as above, but this time I'm using the container:

```bash
export INPUT_CMD_PARAMS="--skip-tls-verification --verbose"
export INPUT_PAGES_PATH="${PWD}/tests/"
export INPUT_URL="https://my-testing-domain.com"
docker run --rm -t -e INPUT_URL -e INPUT_CMD_PARAMS -e INPUT_PAGES_PATH -v "$INPUT_PAGES_PATH:$INPUT_PAGES_PATH" peru/action-test
```

## Parameters

Environment variables used by `./entrypoint.sh` script.

| Variable            | Default                               | Description                                                                                                                                                               |
|---------------------|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `INPUT_CMD_PARAMS`  | --buffer-size=8192 --concurrency=10   | Command line parameters for URL checker [muffet](https://github.com/raviqqe/muffet) (Details [here](https://github.com/raviqqe/muffet/blob/master/arguments.go#L16-L34)) |
| `INPUT_DEBUG`       | false                                 | Enable debug mode for the `./entrypoint.sh` script (set -x)                                                                                                              |
| `INPUT_PAGES_PATH`  | ''                                    | Relative path to the directory with local web pages                                                                                                                      |
| `INPUT_RUN_TIMEOUT` | 600                                   | Max number of seconds which URL checker can be running                                                                                                                   |
| `INPUT_URL`         | '' (**Required**)                     | URL which will be checked                                                                                                                                                |

## Full examples

GitHub Action example:

```yaml
name: Checks

on:
  push:
    branches:
    - master

jobs:
  build-deploy:
    runs-on: ubuntu-18.04
    steps:
      - name: Create web page
        run: |
          mkdir -v public
          cat > public/index.html << EOF
          <!DOCTYPE html>
          <html>
            <head>
              My page which will be stored on my-testing-domain.com domain
            </head>
            <body>
              Links:
              <ul>
                <li><a href="https://google.com">https://google.com</a></li>
                <li><a href="https://my-testing-domain.com">https://my-testing-domain.com</a></li>
                <li><a href="https://my-testing-domain.com:443">https://my-testing-domain.com:443</a></li>
              </ul>
            </body>
          </html>
          EOF

      - name: Check links using script
        env:
          INPUT_URL: https://my-testing-domain.com
          INPUT_PAGES_PATH: ./public/
          INPUT_CMD_PARAMS: "--buffer-size=8192 --concurrency=10 --skip-tls-verification --ignore-fragments"
          INPUT_RUN_TIMEOUT: 100
          INPUT_DEBUG: true
        run: |
          wget -qO- https://raw.githubusercontent.com/ruzickap/action-test/v1/entrypoint.sh | bash

      - name: Check links using container
        uses: ruzickap/action-test@v1
        with:
          url: https://my-testing-domain.com
          pages_path: ./public/
          cmd_params: "--buffer-size=8192 --concurrency=10 --skip-tls-verification --ignore-fragments"
          run_timeout: 100
          debug: true
```

## Examples

Some other examples of building web pages using [Static Site Generators](https://www.staticgen.com/)
and GitHub Actions can be found here: [https://github.com/peaceiris/actions-gh-pages/](https://github.com/peaceiris/actions-gh-pages/)

Few real examples:

* Static page generated by [Hugo](https://gohugo.io/)
  and links checked: [example](https://github.com/ruzickap/xvx.cz/blob/master/.github/workflows/hugo-build.yml)
* Static page generated by [VuePress](https://vuepress.vuejs.org/)
  and links checked: [example](https://github.com/ruzickap/k8s-harbor/blob/master/.github/workflows/build.yml)
