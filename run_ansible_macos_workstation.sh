#!/bin/bash


ansible-playbook --diff --connection=local 127.0.0.1 main.yml
