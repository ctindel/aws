#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

# Update the box
source /etc/os-release
apt-get -y install build-essential dkms

# Upgrade to the latest kernels
apt-get -y upgrade linux-generic
apt-get -y upgrade

# Finally upgrade all dependent packages including kernel
apt-get -y dist-upgrade
reboot
sleep 60
