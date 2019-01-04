#!/bin/bash -e

export DEBIAN_FRONTEND=noninteractive

# turn down kswapd activity
echo "vm.swappiness=0" >> /etc/sysctl.conf
echo 1 > /proc/sys/vm/drop_caches
