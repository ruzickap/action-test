# GitHub Actions for checking broken links ✔

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Broken%20Link%20Checker-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/broken-link-checker)
[![license](https://img.shields.io/github/license/ruzickap/action-broken-link-checker.svg)](https://github.com/ruzickap/action-broken-link-checker/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/ruzickap/action-broken-link-checker.svg)](https://github.com/ruzickap/action-broken-link-checker/releases/latest)
[![GitHub release date](https://img.shields.io/github/release-date/ruzickap/action-broken-link-checker.svg)](https://github.com/ruzickap/action-broken-link-checker/releases)
![GitHub Actions status](https://github.com/ruzickap/action-broken-link-checker/workflows/docker-image/badge.svg)
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/peru/broken-link-checker.svg)](https://hub.docker.com/r/peru/broken-link-checker)

This is a GitHub Action to check broken link in your static files or web pages.
The [muffet](https://github.com/raviqqe/muffet) is used for checking
the web pages.

See the basic GitHub Action example to run periodic checks (weekly)
if there are broken links on the [google.com](https://google.com)
page:

```yaml
on:
  schedules:
    - cron: 0 0 * * 0

name: Check markdown links
jobs:
  broken-link-checker:
    name: Check broken links
    runs-on: ubuntu-18.04
    steps:
    - name: Check
      uses: ruzickap/action-broken-link-checker@v1
      env:
        URL: https://www.google.com
```

Here is the screenshot with output:

This deploy action can be combined simply and freely with Static Site
Generators. (Hugo, MkDocs, Gatsby, GitBook, mdBook, etc.). The following
examples expects to have the web page stored in `./build` directory. There is a
[caddy](https://caddyserver.com/) started during the tests which is using the
hostname from the `URL` parameter and serving the web page (see the details in
[entrypoint.sh](./entrypoint.sh)).

```yaml
- name: Check
  uses: ruzickap/action-broken-link-checker@v1
  env:
    URL: https://www.example.com/test123
    PAGES_PATH: ./build
    MUFFET_CMD_PARAMS: --buffer-size=8192 --concurrency=10 --skip-tls-verification --limit-redirections=5 --timeout=20  # Specify all necessary muffet parameters
    RUN_TIMEOUT: 600  # Maximum amount of time to run muffet (default is 300 seconds)
```

Do you want to skip the docker build step? OK, the script mode is available.

```yaml
- name: Check
  env:
    URL: https://www.example.com/test123
    PAGES_PATH: ./build
    MUFFET_CMD_PARAMS: --buffer-size=8192 --concurrency=10 --skip-tls-verification  # Mandatory parameter when using https and "PAGES_PATH"
  run: |
    wget https://raw.githubusercontent.com/ruzickap/action-broken-link-checker/v1/entrypoint.sh
    bash ./entrypoint.sh
```

It's possible to use the script locally. It will install [caddy](https://caddyserver.com/)
and [muffet](https://github.com/raviqqe/muffet) binaries if they
are not already installed on your system.

```bash
export URL="https://google.com"
export MUFFET_CMD_PARAMS="--buffer-size=8192 --one-page-only --verbose"
./entrypoint.sh
```

Full example:

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
              My page on the my-testing-domain.com domain
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

      - name: Check
        env:
          URL: https://my-testing-domain.com
          PAGES_PATH: ./public
          MUFFET_CMD_PARAMS: --buffer-size=8192 --concurrency=10 --skip-tls-verification
        run: |
          wget https://raw.githubusercontent.com/ruzickap/action-broken-link-checker/v1/entrypoint.sh
          bash ./entrypoint.sh
```

## Examples

Few real examples:

* Check [Hugo](https://gohugo.io/) generated web pages using GitHub pages: [https://github.com/ruzickap/xvx.cz/blob/master/.github/workflows/hugo-build.yml](https://github.com/ruzickap/xvx.cz/blob/master/.github/workflows/hugo-build.yml)
* Check [VuePress](https://vuepress.vuejs.org/) generated web pages: [https://github.com/ruzickap/k8s-harbor/blob/master/.github/workflows/build.yml](https://github.com/ruzickap/k8s-harbor/blob/master/.github/workflows/build.yml)
