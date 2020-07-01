#!/bin/bash

ansible-playbook --diff -e ansible_python_interpreter=$(which python3) --connection=local -i "127.0.0.1," main.yml
