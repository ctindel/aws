#!/bin/bash -eux

# Allow https transport
apt-get install -y apt-transport-https ca-certificates

# Redirect from /dev/null to disable the prompts
add-apt-repository ppa:saiarcot895/myppa < /dev/null
apt-get update 

apt-get install -y apt-file
apt-file update

echo debconf apt-fast/maxdownloads string 16 | debconf-set-selections
echo debconf apt-fast/dlflag boolean true | debconf-set-selections
echo debconf apt-fast/aptmanager string apt-get | debconf-set-selections
apt-get install -y apt-fast

# lsb-release provides release ver in /etc/os-release as VERSION_ID
apt-get install -y lsb-release
