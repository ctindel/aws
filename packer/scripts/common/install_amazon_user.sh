#!/bin/bash

if [[ ! $PACKER_BUILDER_TYPE =~ docker ]]
then
    groupadd amazon
    useradd -m -g amazon -s /bin/bash amazon

    mkdir /home/amazon/.ssh
    cp /var/tmp/amazon.pub /home/amazon/.ssh/authorized_keys
    chown -R amazon:amazon /home/amazon/.ssh
    chmod 0700 /home/amazon/.ssh
    chmod -R 0600 /home/amazon/.ssh/*

    # Set up sudo
    echo 'Defaults:amazon !requiretty' > /etc/sudoers.d/amazon
    echo 'amazon ALL = (ALL) NOPASSWD: ALL' >> /etc/sudoers.d/amazon
    chmod 0440 /etc/sudoers.d/amazon

    rm /var/tmp/amazon.pub
fi
