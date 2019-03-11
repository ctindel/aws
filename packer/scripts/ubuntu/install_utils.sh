#!/bin/bash

apt-get install -y zip nmap sysstat jq 

# These are necessary for building python from source with pyenv
apt-get install -y zlib1g zlib1g-dev libffi-dev libssl-dev libreadline-dev libbz2-dev libsqlite3-dev
