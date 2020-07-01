#!/bin/bash

ansible-playbook --extra-vars "homebrew_casks=iterm2 -e homebrew=dockutil,fzf,romkatv/powerlevel10k/powerlevel10k" --connection=local -i "127.0.0.1," main.yml
