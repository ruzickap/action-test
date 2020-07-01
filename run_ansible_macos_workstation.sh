#!/bin/bash

ansible-playbook --diff --connection=local -i "127.0.0.1," main.yml
