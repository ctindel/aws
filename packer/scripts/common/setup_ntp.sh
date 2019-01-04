#!/bin/bash

apt-get install -y ntp
systemctl enable ntp
systemctl start ntp
