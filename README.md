# GitHub Actions for checking broken links ✔

[![GitHub Marketplace](https://img.shields.io/badge/Marketplace-Broken%20Link%20Checker-blue.svg?colorA=24292e&colorB=0366d6&style=flat&longCache=true&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAYAAAAfSC3RAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAAM6wAADOsB5dZE0gAAABl0RVh0U29mdHdhcmUAd3d3Lmlua3NjYXBlLm9yZ5vuPBoAAAERSURBVCiRhZG/SsMxFEZPfsVJ61jbxaF0cRQRcRJ9hlYn30IHN/+9iquDCOIsblIrOjqKgy5aKoJQj4O3EEtbPwhJbr6Te28CmdSKeqzeqr0YbfVIrTBKakvtOl5dtTkK+v4HfA9PEyBFCY9AGVgCBLaBp1jPAyfAJ/AAdIEG0dNAiyP7+K1qIfMdonZic6+WJoBJvQlvuwDqcXadUuqPA1NKAlexbRTAIMvMOCjTbMwl1LtI/6KWJ5Q6rT6Ht1MA58AX8Apcqqt5r2qhrgAXQC3CZ6i1+KMd9TRu3MvA3aH/fFPnBodb6oe6HM8+lYHrGdRXW8M9bMZtPXUji69lmf5Cmamq7quNLFZXD9Rq7v0Bpc1o/tp0fisAAAAASUVORK5CYII=)](https://github.com/marketplace/actions/broken-link-checker)
[![license](https://img.shields.io/github/license/ruzickap/action-broken-link-checker.svg)](https://github.com/ruzickap/action-broken-link-checker/blob/master/LICENSE)
[![release](https://img.shields.io/github/release/ruzickap/action-broken-link-checker.svg)](https://github.com/ruzickap/action-broken-link-checker/releases/latest)
[![GitHub release date](https://img.shields.io/github/release-date/ruzickap/action-broken-link-checker.svg)](https://github.com/ruzickap/action-broken-link-checker/releases)
![GitHub Actions status](https://github.com/ruzickap/action-broken-link-checker/workflows/docker%20image%20ci/badge.svg)
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/peru/broken-link-checker.svg)](https://hub.docker.com/r/peru/broken-link-checker)


This is a GitHub Action to check broken link in your static files or web pages.
The [muffet](https://github.com/raviqqe/muffet) is used for checking
the web pages.

See the basic GitHub Action example to run periodic check (weekly)
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
    runs-on: ubuntu-latest
    steps:
    - name: Check
      uses: ruzickap/action-broken-link-checker@v1
      env:
        URL: https://www.google.com
```

This deploy action can be combined simply and freely with Static Site
Generators. (Hugo, MkDocs, Gatsby, GitBook, mdBook, etc.)

```yaml
- name: Check
  uses: ruzickap/action-broken-link-checker@v1
  env:
    URL: https://www.example.com/test123
    PAGES_PATH: /build/
```

```yaml
- name: Check
  uses: ruzickap/action-broken-link-checker@v1
  env:
    URL: https://www.example.com/test123
    PAGES_PATH: /build/
    MUFFET_CMD_PARAMS: --limit-redirections=5 --follow-robots-txt --timeout=20
```

Do you want to skip the docker build step? OK, the script mode is available.

```yaml
- name: Check
  env:
    ACTIONS_DEPLOY_KEY: ${{ secrets.ACTIONS_DEPLOY_KEY }}
    PUBLISH_BRANCH: gh-pages
    PUBLISH_DIR: ./public
    SCRIPT_MODE: true
  run: |
    wget https://raw.githubusercontent.com/ruzickap/action-broken-link-checker/v1/entrypoint.sh
    bash ./entrypoint.sh
```




```yaml
name: github pages

on:
  push:
    branches:
    - master

jobs:
  build-deploy:
    runs-on: ubuntu-18.04
    steps:
    - uses: actions/checkout@v2
      with:
        submodules: true

    - name: Setup Hugo
      uses: peaceiris/actions-hugo@v2
      with:
        hugo-version: '0.60.0'

    - name: Build
      run: hugo --minify



    - name: Deploy
      uses: peaceiris/actions-gh-pages@v2
      env:
        ACTIONS_DEPLOY_KEY: ${{ secrets.ACTIONS_DEPLOY_KEY }}
        PUBLISH_BRANCH: gh-pages
        PUBLISH_DIR: ./public
```
