#!/bin/bash -e
source /etc/os-release

if [ ${VERSION_ID%%.*} -ge 16 ]
then
    # Disable apt-daily timer
    systemctl stop apt-daily.timer
    systemctl disable apt-daily.timer

    # If apt-daily.timer gets enabled again, prevent immediate start upon first
    # launch if scheduled updates have been missed
    mkdir -p /etc/systemd/system/apt-daily.timer.d
    cat >/etc/systemd/system/apt-daily.timer.d/apt-daily.timer.conf <<-EOF
[Timer]
Persistent=false
EOF
fi
