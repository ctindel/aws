#!/bin/bash

# Not all AMIs should have the private key installed, like the honeypot AMI
if [[ ! $PACKER_BUILDER_TYPE =~ docker ]]
then
    cp /var/tmp/amazon.key /home/amazon/.ssh/amazon.key
    chmod 400 /home/amazon/.ssh/amazon.key
    rm -f /var/tmp/amazon.key

    cat << EOF > /home/amazon/.ssh/config
Host *
  IdentityFile /home/amazon/.ssh/amazon.key
  TCPKeepAlive no
  ServerAliveCountMax 8
  ServerAliveInterval 15
  HashKnownHosts no
  ForwardAgent yes
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOF
    chmod 600 /home/amazon/.ssh/config

fi
